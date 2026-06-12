import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'secure_storage_service.dart';

/// Manages authentication session state, token refresh, and expiration.
///
/// Extends [ChangeNotifier] so it can be used as GoRouter's
/// [refreshListenable] to trigger route re-evaluation on auth changes.
///
/// Security: Tokens are never stored in SharedPreferences or Isar.
/// All token operations go through [SecureStorageService].
class SessionManager extends ChangeNotifier {
  SessionManager({
    required SecureStorageService secureStorage,
    required SupabaseClient supabase,
  })  : _secureStorage = secureStorage,
        _supabase = supabase;

  final SecureStorageService _secureStorage;
  final SupabaseClient _supabase;

  Timer? _refreshTimer;
  final StreamController<SessionState> _sessionController =
      StreamController<SessionState>.broadcast();

  /// Stream of session state changes.
  Stream<SessionState> get sessionStream => _sessionController.stream;

  /// Current session state.
  SessionState _currentState = SessionState.unknown;
  SessionState get currentState => _currentState;

  /// Initialize session from stored credentials.
  Future<void> initialize() async {
    final hasSession = await _secureStorage.hasSession();
    if (!hasSession) {
      _updateState(SessionState.unauthenticated);
      return;
    }

    try {
      final session = _supabase.auth.currentSession;
      if (session != null && !session.isExpired) {
        await _persistSession(session);
        _updateState(SessionState.authenticated);
        _scheduleTokenRefresh(session);
      } else if (session != null && session.isExpired) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          _updateState(SessionState.authenticated);
        } else {
          await _secureStorage.clearAll();
          _updateState(SessionState.unauthenticated);
        }
      } else {
        await _secureStorage.clearAll();
        _updateState(SessionState.unauthenticated);
      }
    } catch (e) {
      await _secureStorage.clearAll();
      _updateState(SessionState.unauthenticated);
    }
  }

  /// Persist session data to secure storage after successful auth.
  Future<void> persistAuth({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String email,
    required int expiresAt,
  }) async {
    final expiryMs = _expiresAtToMilliseconds(expiresAt);
    await _secureStorage.storeAccessToken(accessToken);
    await _secureStorage.storeRefreshToken(refreshToken);
    await _secureStorage.storeUserId(userId);
    await _secureStorage.storeUserEmail(email);
    await _secureStorage.storeSessionExpiry(expiryMs);
    _updateState(SessionState.authenticated);
  }

  /// Handle Supabase session and persist it.
  Future<void> _persistSession(Session session) async {
    final expiryMs = _expiresAtToMilliseconds(session.expiresAt);
    final userId = _supabase.auth.currentUser?.id ?? '';
    final email = _supabase.auth.currentUser?.email ?? '';
    final refreshToken = session.refreshToken ?? '';

    await _secureStorage.storeAccessToken(session.accessToken);
    await _secureStorage.storeRefreshToken(refreshToken);
    await _secureStorage.storeUserId(userId);
    await _secureStorage.storeUserEmail(email);
    await _secureStorage.storeSessionExpiry(expiryMs);
  }

  /// Check if the current session is valid (not expired).
  Future<bool> isSessionValid() async {
    final expiry = await _secureStorage.getSessionExpiry();
    if (expiry == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    return now < (expiry - 30000);
  }

  /// Attempt to refresh the access token using the stored refresh token.
  Future<bool> _tryRefreshToken() async {
    try {
      final response = await _supabase.auth.refreshSession();
      if (response.session != null) {
        await _persistSession(response.session!);
        _scheduleTokenRefresh(response.session!);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Schedule automatic token refresh before expiry.
  void _scheduleTokenRefresh(Session session) {
    _refreshTimer?.cancel();

    final expiresAtMs = _expiresAtToMilliseconds(session.expiresAt);
    if (expiresAtMs == 0) return;

    final expiresAt = DateTime.fromMillisecondsSinceEpoch(expiresAtMs);
    final refreshAt = expiresAt.subtract(const Duration(minutes: 5));
    final delay = refreshAt.difference(DateTime.now());

    if (delay.isNegative) {
      _tryRefreshToken();
      return;
    }

    _refreshTimer = Timer(delay, () async {
      final refreshed = await _tryRefreshToken();
      if (!refreshed) {
        _updateState(SessionState.expired);
      }
    });
  }

  int _expiresAtToMilliseconds(int? expiresAt) {
    if (expiresAt == null || expiresAt <= 0) return 0;
    return expiresAt < 1000000000000 ? expiresAt * 1000 : expiresAt;
  }

  /// Handle session expiration — clear state and notify listeners.
  Future<void> onSessionExpired() async {
    _refreshTimer?.cancel();
    await _secureStorage.clearAll();
    _updateState(SessionState.expired);
  }

  void _updateState(SessionState state) {
    _currentState = state;
    _sessionController.add(state);
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _sessionController.close();
    super.dispose();
  }
}

/// Represents the possible states of an authentication session.
enum SessionState { unknown, authenticated, unauthenticated, expired }
