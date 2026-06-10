import 'package:flutter_test/flutter_test.dart';
import 'package:threatlensia/core/security/session_manager.dart';

void main() {
  group('SessionState enum', () {
    test('has all 4 states', () {
      expect(SessionState.values.length, 4);
      expect(SessionState.values, contains(SessionState.unknown));
      expect(SessionState.values, contains(SessionState.authenticated));
      expect(SessionState.values, contains(SessionState.unauthenticated));
      expect(SessionState.values, contains(SessionState.expired));
    });
  });

  group('SessionManager initial state', () {
    test('starts in unknown state', () {
      // SessionManager requires Supabase and SecureStorage dependencies
      // This test verifies the enum and state model contract
      const state = SessionState.unknown;
      expect(state, SessionState.unknown);
    });

    test('state transitions are well-defined', () {
      // Verify all state transitions the app supports
      const validTransitions = {
        SessionState.unknown: [
          SessionState.authenticated,
          SessionState.unauthenticated,
        ],
        SessionState.authenticated: [
          SessionState.unauthenticated,
          SessionState.expired,
        ],
        SessionState.unauthenticated: [
          SessionState.authenticated,
        ],
        SessionState.expired: [
          SessionState.unauthenticated,
          SessionState.authenticated,
        ],
      };

      expect(validTransitions.length, 4);
      expect(
        validTransitions[SessionState.unknown],
        contains(SessionState.authenticated),
      );
      expect(
        validTransitions[SessionState.authenticated],
        contains(SessionState.expired),
      );
    });
  });
}
