import 'dart:math' as math;

import 'package:dio/dio.dart';

/// Interceptor that retries failed requests with exponential backoff.
///
/// Retries on:
/// - Connection errors (no internet)
/// - Server errors (5xx)
/// - Rate limiting (429)
///
/// Does NOT retry on:
/// - Client errors (4xx except 429)
/// - Authentication errors (401, 403)
/// - Cancelled requests
///
/// Safety: Uses the [extra] map on [RequestOptions] to track retry count,
/// preventing infinite recursion when re-fetching through the same
/// interceptor chain.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required Dio dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
  }) : _dio = dio;

  final Dio _dio;
  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;

  static const _retryKey = 'retry_count';

  int _getRetryCount(RequestOptions options) {
    return (options.extra[_retryKey] as int?) ?? 0;
  }

  void _setRetryCount(RequestOptions options, int count) {
    options.extra[_retryKey] = count;
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = _getRetryCount(err.requestOptions);

    if (_shouldRetry(err) && retryCount < maxRetries) {
      final delay = _calculateDelay(retryCount);
      await Future<void>.delayed(delay);

      // Increment retry count before re-fetching
      _setRetryCount(err.requestOptions, retryCount + 1);

      try {
        final response = await _dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // Don't retry if the request was cancelled
    if (err.type == DioExceptionType.cancel) return false;

    // Don't retry client errors (except 429 rate limiting)
    final statusCode = err.response?.statusCode;
    if (statusCode != null) {
      if (statusCode == 429) return true; // Rate limited
      if (statusCode >= 400 && statusCode < 500) return false;
    }

    // Retry connection errors and timeouts
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    // Retry server errors (5xx)
    if (statusCode != null && statusCode >= 500) return true;

    return false;
  }

  /// Calculate delay with exponential backoff and jitter.
  ///
  /// Formula: min(baseDelay * 2^retryCount, maxDelay) + random jitter
  Duration _calculateDelay(int retryCount) {
    final exponentialMs =
        baseDelay.inMilliseconds * math.pow(2, retryCount).toInt();
    final cappedMs = math.min(exponentialMs, maxDelay.inMilliseconds);
    final jitterMs = math.Random().nextInt(1000); // 0-1s jitter
    return Duration(milliseconds: cappedMs + jitterMs);
  }
}

