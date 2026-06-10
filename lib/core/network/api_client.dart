import 'package:dio/dio.dart';

import '../security/secure_storage_service.dart';
import '../exceptions/app_exceptions.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Centralized HTTP client for all network communication.
///
/// Security requirements (OWASP MASVS):
/// - All API calls go through this single client
/// - Auth tokens are injected via interceptor, never hardcoded
/// - Sensitive data is redacted from logs
/// - Timeouts prevent hanging connections
/// - Retry logic uses exponential backoff
/// - No tokens appear in logs
/// - No PII appears in analytics
///
/// Architecture: Mobile app communicates only with Supabase Edge Functions.
/// AI provider credentials live server-side and never reach the client.
class ApiClient {
  ApiClient({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage {
    _dio = _configureDio();
  }

  late final Dio _dio;
  final SecureStorageService _secureStorage;

  /// The underlying [Dio] instance — use for direct calls if needed.
  Dio get dio => _dio;

  Dio _configureDio() {
    final dio = Dio();

    // Base configuration
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 15);

    // Add interceptors in order
    dio.interceptors.addAll([
      RetryInterceptor(dio: dio),
      AuthInterceptor(secureStorage: _secureStorage),
      AppLoggingInterceptor(),
    ]);

    return dio;
  }

  /// Perform a GET request.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Perform a POST request.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Perform a PUT request.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Perform a DELETE request.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Convert Dio exceptions to typed app exceptions.
  static AppException handleError(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return NetworkException(
            message: 'Connection timed out. Please check your network.',
            originalError: error,
          );
        case DioExceptionType.connectionError:
          return NetworkException(
            message: 'No internet connection.',
            originalError: error,
          );
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return AuthenticationException(
              message: 'Session expired. Please log in again.',
              originalError: error,
            );
          }
          if (statusCode == 403) {
            return AuthenticationException(
              message: 'Access denied.',
              originalError: error,
            );
          }
          return NetworkException(
            message: 'Server error ($statusCode). Please try again.',
            originalError: error,
          );
        case DioExceptionType.cancel:
          return NetworkException(
            message: 'Request was cancelled.',
            originalError: error,
          );
        case DioExceptionType.unknown:
          return NetworkException(
            message: 'An unexpected error occurred.',
            originalError: error,
          );
        case DioExceptionType.badCertificate:
          return NetworkException(
            message: 'Certificate verification failed.',
            originalError: error,
          );
      }
    }
    return NetworkException(
      message: 'An unexpected error occurred.',
      originalError: error,
    );
  }
}
