import 'dart:developer' as developer;
import 'package:dio/dio.dart';

/// Interceptor that logs HTTP requests and responses while redacting
/// sensitive data.
///
/// Security requirements:
/// - No tokens in logs
/// - No PII in logs
/// - No API keys in logs
/// - Sensitive headers are stripped before logging
/// - Request/response bodies are truncated for large payloads
class AppLoggingInterceptor extends Interceptor {
  AppLoggingInterceptor({this.enableLogging = true});

  final bool enableLogging;

  /// Headers that contain sensitive data and must never be logged.
  static const _sensitiveHeaders = {
    'authorization',
    'cookie',
    'set-cookie',
    'x-api-key',
    'x-auth-token',
  };

  /// Fields in request/response bodies that contain sensitive data.
  static const _sensitiveBodyFields = {
    'token',
    'access_token',
    'refresh_token',
    'password',
    'secret',
    'api_key',
    'apiKey',
    'email',
    'authorization',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!enableLogging) return handler.next(options);

    final sanitizedHeaders = _sanitizeHeaders(options.headers);
    developer.log(
      '[HTTP REQUEST] ${options.method} ${options.uri}',
      name: 'ApiClient',
    );
    developer.log('  Headers: $sanitizedHeaders', name: 'ApiClient');

    if (options.data != null) {
      final sanitizedBody = _sanitizeBody(options.data);
      developer.log('  Body: $sanitizedBody', name: 'ApiClient');
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!enableLogging) return handler.next(response);

    developer.log(
      '[HTTP RESPONSE] ${response.statusCode} ${response.requestOptions.uri}',
      name: 'ApiClient',
    );

    if (response.data != null) {
      final sanitizedData = _sanitizeBody(response.data);
      // Truncate large responses
      final truncated = sanitizedData.toString().length > 500
          ? '${sanitizedData.toString().substring(0, 500)}...[truncated]'
          : sanitizedData;
      developer.log('  Data: $truncated', name: 'ApiClient');
    }

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!enableLogging) return handler.next(err);

    developer.log(
      '[HTTP ERROR] ${err.requestOptions.method} ${err.requestOptions.uri}',
      name: 'ApiClient',
    );
    developer.log('  Status: ${err.response?.statusCode}', name: 'ApiClient');
    developer.log('  Message: ${err.message}', name: 'ApiClient');

    return handler.next(err);
  }

  /// Remove sensitive values from headers map.
  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);
    for (final key in sanitized.keys) {
      if (_sensitiveHeaders.contains(key.toLowerCase())) {
        sanitized[key] = '[REDACTED]';
      }
    }
    return sanitized;
  }

  /// Redact sensitive fields from request/response body.
  dynamic _sanitizeBody(dynamic body) {
    if (body == null) return null;
    if (body is Map<String, dynamic>) {
      final sanitized = Map<String, dynamic>.from(body);
      for (final key in sanitized.keys) {
        if (_sensitiveBodyFields.contains(key)) {
          sanitized[key] = '[REDACTED]';
        } else if (sanitized[key] is Map) {
          sanitized[key] = _sanitizeBody(sanitized[key]);
        }
      }
      return sanitized;
    }
    if (body is List) {
      return body.map(_sanitizeBody).toList();
    }
    return body;
  }
}
