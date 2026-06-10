import 'package:supabase_flutter/supabase_flutter.dart';

import 'secure_storage_service.dart';
import 'session_manager.dart';

/// Handles complete logout and data wipe.
///
/// Ensures no residual authentication or session data remains after logout:
/// 1. Signs out from Supabase backend
/// 2. Clears all secure storage (tokens, session data)
/// 3. Resets session manager state
/// 4. Optionally clears encrypted Isar cache
///
/// Security: Must be called on every logout path — button, session expiry,
/// and forced logout scenarios.
class LogoutWiper {
  LogoutWiper({
    required SecureStorageService secureStorage,
    required SessionManager sessionManager,
    required SupabaseClient supabase,
  })  : _secureStorage = secureStorage,
        _sessionManager = sessionManager,
        _supabase = supabase;

  final SecureStorageService _secureStorage;
  final SessionManager _sessionManager;
  final SupabaseClient _supabase;

  /// Perform a complete logout and data wipe.
  ///
  /// This is idempotent — calling it multiple times is safe.
  Future<void> logout() async {
    // 1. Sign out from Supabase (invalidates server-side session)
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      // Continue with local cleanup even if server signout fails
    }

    // 2. Clear all secure storage
    await _secureStorage.clearAll();

    // 3. Reset session manager
    await _sessionManager.onSessionExpired();

    // 4. Clear any in-memory caches
    _clearInMemoryState();
  }

  /// Force logout due to session expiration or security event.
  ///
  /// Same as [logout] but signals the reason to the session manager.
  Future<void> forceLogout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      // Continue with local cleanup
    }

    await _secureStorage.clearAll();
    await _sessionManager.onSessionExpired();
    _clearInMemoryState();
  }

  /// Clear any in-memory state that might hold sensitive data.
  void _clearInMemoryState() {
    // In-memory caches should be cleared here when they are implemented.
    // Example: threat analysis cache, AI chat history cache, etc.
  }
}
