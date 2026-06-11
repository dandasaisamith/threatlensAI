import 'package:dio/dio.dart';

import '../../security/secure_storage_service.dart';

/// Interceptor that injects authentication tokens into outgoing requests.
///
/// Reads the access token from [SecureStorageService] (never from
/// SharedPreferences or plain storage) and adds it as a Bearer token.
///
/// Security: Tokens are read fresh for each request to handle refresh.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage;

  final SecureStorageService _secureStorage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip auth for public endpoints
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // If 401, the token is invalid — let the app handle session expiry
    if (err.response?.statusCode == 401) {
      // Session expired — app should trigger logout flow
    }
    return handler.next(err);
  }

  bool _isPublicEndpoint(String path) {
    const publicPaths = [
      '/auth/v1/token',
      '/auth/v1/signup',
      '/auth/v1/otp',
    ];
    return publicPaths.any((p) => path.contains(p));
  }
}
