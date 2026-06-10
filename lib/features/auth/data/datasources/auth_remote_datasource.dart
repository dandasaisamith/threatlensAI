import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

/// Remote data source for authentication operations.
///
/// Wraps Supabase auth client and provides a clean data layer interface.
/// This is the lowest-level data access — all auth network calls go through here.
class AuthRemoteDataSource {
  AuthRemoteDataSource({required SupabaseClient supabase})
      : _supabase = supabase;

  final SupabaseClient _supabase;

  /// Sign in with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email and password.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign out.
  Future<void> signOut() => _supabase.auth.signOut();

  /// Get current session.
  Session? get currentSession => _supabase.auth.currentSession;

  /// Get current user.
  User? get currentUser => _supabase.auth.currentUser;

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Send password reset email.
  Future<void> resetPassword(String email) =>
      _supabase.auth.resetPasswordForEmail(email);
}
