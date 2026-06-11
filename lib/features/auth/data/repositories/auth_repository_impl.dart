import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../domain/repositories/auth_repository.dart';
import '../../../../core/security/secure_storage_service.dart';
import '../../../../core/security/session_manager.dart';

/// Data layer implementation of [AuthRepository].
///
/// Coordinates between Supabase backend and secure storage.
/// The presentation layer depends only on the [AuthRepository] interface.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required SupabaseClient supabase,
    required SecureStorageService secureStorage,
    required SessionManager sessionManager,
  })  : _supabase = supabase,
        _secureStorage = secureStorage,
        _sessionManager = sessionManager;

  final SupabaseClient _supabase;
  final SecureStorageService _secureStorage;
  final SessionManager _sessionManager;

  int _expiresAtToMilliseconds(int? expiresAt) {
    if (expiresAt == null || expiresAt <= 0) return 0;
    return expiresAt < 1000000000000 ? expiresAt * 1000 : expiresAt;
  }

  /// Helper to safely convert nullable Supabase User to AuthUser.
  AuthUser? _toAuthUser(User? supabaseUser) {
    if (supabaseUser == null) return null;
    final metadata = supabaseUser.userMetadata;
    final displayName = metadata?['display_name'] as String?;
    final createdAtStr = supabaseUser.createdAt;
    final lastSignInStr = supabaseUser.lastSignInAt;
    return AuthUser(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      displayName: displayName,
      createdAt: createdAtStr.isNotEmpty
          ? DateTime.tryParse(createdAtStr)
          : null,
      lastSignInAt: lastSignInStr != null && lastSignInStr.isNotEmpty
          ? DateTime.tryParse(lastSignInStr)
          : null,
    );
  }

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session == null || response.user == null) {
      throw Exception('Sign in failed: no session returned');
    }

    final session = response.session!;
    final appUser = _toAuthUser(response.user)!;
    final expiryMs = _expiresAtToMilliseconds(session.expiresAt);
    final refreshToken = session.refreshToken ?? '';

    await _sessionManager.persistAuth(
      accessToken: session.accessToken,
      refreshToken: refreshToken,
      userId: appUser.id,
      email: appUser.email,
      expiresAt: expiryMs,
    );

    return AuthResult(
      user: appUser,
      accessToken: session.accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(expiryMs),
    );
  }

  @override
  Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Sign up failed: no user returned');
    }

    final appUser = _toAuthUser(response.user)!;
    final session = response.session;

    if (session == null) {
      return AuthResult(
        user: appUser,
        requiresEmailVerification: true,
      );
    }

    final expiryMs = _expiresAtToMilliseconds(session.expiresAt);
    final refreshToken = session.refreshToken ?? '';

    await _sessionManager.persistAuth(
      accessToken: session.accessToken,
      refreshToken: refreshToken,
      userId: appUser.id,
      email: appUser.email,
      expiresAt: expiryMs,
    );

    return AuthResult(
      user: appUser,
      accessToken: session.accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(expiryMs),
    );
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await _secureStorage.clearAll();
    await _sessionManager.onSessionExpired();
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    return _toAuthUser(_supabase.auth.currentUser);
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((event) {
      final session = event.session;
      if (session == null) return null;
      return _toAuthUser(session.user);
    });
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}
