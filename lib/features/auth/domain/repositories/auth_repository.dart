/// Repository interface for authentication operations.
///
/// Defines the contract between the presentation/data layers.
/// The data layer implements this; the presentation layer depends only on this.
///
/// Domain layer rules:
/// - No Flutter imports
/// - No Dio imports
/// - No Supabase imports
/// - Pure Dart only
abstract class AuthRepository {
  /// Sign in with email and password.
  Future<AuthResult> signIn({required String email, required String password});

  /// Sign up with email and password.
  Future<AuthResult> signUp({required String email, required String password});

  /// Sign out and clear all session data.
  Future<void> signOut();

  /// Get the currently authenticated user, or null if not authenticated.
  Future<AuthUser?> getCurrentUser();

  /// Stream of auth state changes.
  Stream<AuthUser?> get authStateChanges;

  /// Send a password reset email.
  Future<void> sendPasswordResetEmail(String email);
}

/// Domain-level user entity for auth operations.
///
/// Named AuthUser to avoid collision with Supabase's User type.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    this.createdAt,
    this.lastSignInAt,
  });

  final String id;
  final String email;
  final String? displayName;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;
}

/// Result of an authentication operation.
class AuthResult {
  const AuthResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  final AuthUser user;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
}
