import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for sensitive data (tokens, keys, session data).
///
/// Uses [FlutterSecureStorage] which encrypts data at rest using the
/// platform keystore (Android Keystore / iOS Keychain).
///
/// Security rules (OWASP MASVS):
/// - Never store tokens in SharedPreferences or plain files
/// - Never log stored values
/// - Wipe all data on logout
class SecureStorageService {
  SecureStorageService({AndroidOptions? androidOptions, IOSOptions? iosOptions})
      : _storage = FlutterSecureStorage(
          aOptions: androidOptions ?? _defaultAndroidOptions,
          iOptions: iosOptions ?? _defaultIOSOptions,
        );

  final FlutterSecureStorage _storage;

  static const AndroidOptions _defaultAndroidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static const IOSOptions _defaultIOSOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  // Storage keys
  static const String _accessTokenKey = 'tl_access_token';
  static const String _refreshTokenKey = 'tl_refresh_token';
  static const String _sessionExpiryKey = 'tl_session_expiry';
  static const String _userIdKey = 'tl_user_id';
  static const String _userEmailKey = 'tl_user_email';

  /// Store the access token securely.
  Future<void> storeAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Retrieve the stored access token.
  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  /// Store the refresh token securely.
  Future<void> storeRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Retrieve the stored refresh token.
  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  /// Store session expiry timestamp (milliseconds since epoch).
  Future<void> storeSessionExpiry(int expiryMs) async {
    await _storage.write(key: _sessionExpiryKey, value: expiryMs.toString());
  }

  /// Retrieve session expiry timestamp, or null if not set.
  Future<int?> getSessionExpiry() async {
    final raw = await _storage.read(key: _sessionExpiryKey);
    if (raw == null) return null;
    return int.tryParse(raw);
  }

  /// Store the authenticated user's ID.
  Future<void> storeUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  /// Retrieve the stored user ID.
  Future<String?> getUserId() async {
    return _storage.read(key: _userIdKey);
  }

  /// Store the authenticated user's email.
  Future<void> storeUserEmail(String email) async {
    await _storage.write(key: _userEmailKey, value: email);
  }

  /// Retrieve the stored user email.
  Future<String?> getUserEmail() async {
    return _storage.read(key: _userEmailKey);
  }

  /// Check whether a session exists (access token is present).
  Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all stored session data.
  ///
  /// Called on logout to ensure no residual auth data remains.
  Future<void> clearAll() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _sessionExpiryKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userEmailKey);
  }

  /// Delete all keys — nuclear option for full data wipe.
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
