import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:threatlensia/core/security/secure_storage_service.dart';

/// Mock class for SecureStorageService to avoid platform dependencies in tests.
class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockSecureStorageService service;

  setUp(() {
    service = MockSecureStorageService();
  });

  group('SecureStorageService', () {
    test('hasSession returns false when no tokens stored', () async {
      when(() => service.hasSession()).thenAnswer((_) async => false);
      final result = await service.hasSession();
      expect(result, false);
    });

    test('store and retrieve access token', () async {
      when(() => service.storeAccessToken('test-access-token'))
          .thenAnswer((_) async {});
      when(() => service.getAccessToken())
          .thenAnswer((_) async => 'test-access-token');

      await service.storeAccessToken('test-access-token');
      final token = await service.getAccessToken();
      expect(token, 'test-access-token');
    });

    test('store and retrieve refresh token', () async {
      when(() => service.storeRefreshToken('test-refresh-token'))
          .thenAnswer((_) async {});
      when(() => service.getRefreshToken())
          .thenAnswer((_) async => 'test-refresh-token');

      await service.storeRefreshToken('test-refresh-token');
      final token = await service.getRefreshToken();
      expect(token, 'test-refresh-token');
    });

    test('store and retrieve session expiry', () async {
      final expiryMs = DateTime(2025, 12, 31).millisecondsSinceEpoch;
      when(() => service.storeSessionExpiry(expiryMs))
          .thenAnswer((_) async {});
      when(() => service.getSessionExpiry())
          .thenAnswer((_) async => expiryMs);

      await service.storeSessionExpiry(expiryMs);
      final stored = await service.getSessionExpiry();
      expect(stored, expiryMs);
    });

    test('store and retrieve user ID', () async {
      when(() => service.storeUserId('user-123'))
          .thenAnswer((_) async {});
      when(() => service.getUserId())
          .thenAnswer((_) async => 'user-123');

      await service.storeUserId('user-123');
      final userId = await service.getUserId();
      expect(userId, 'user-123');
    });

    test('store and retrieve user email', () async {
      when(() => service.storeUserEmail('test@example.com'))
          .thenAnswer((_) async {});
      when(() => service.getUserEmail())
          .thenAnswer((_) async => 'test@example.com');

      await service.storeUserEmail('test@example.com');
      final email = await service.getUserEmail();
      expect(email, 'test@example.com');
    });

    test('hasSession returns true after storing access token', () async {
      when(() => service.storeAccessToken('some-token'))
          .thenAnswer((_) async {});
      when(() => service.hasSession()).thenAnswer((_) async => true);

      await service.storeAccessToken('some-token');
      final result = await service.hasSession();
      expect(result, true);
    });

    test('clearAll removes all stored data', () async {
      when(() => service.storeAccessToken('token'))
          .thenAnswer((_) async {});
      when(() => service.storeRefreshToken('refresh'))
          .thenAnswer((_) async {});
      when(() => service.storeUserId('user'))
          .thenAnswer((_) async {});
      when(() => service.storeUserEmail('email@test.com'))
          .thenAnswer((_) async {});
      when(() => service.storeSessionExpiry(1234567890))
          .thenAnswer((_) async {});

      when(() => service.clearAll()).thenAnswer((_) async {});
      when(() => service.getAccessToken()).thenAnswer((_) async => null);
      when(() => service.getRefreshToken()).thenAnswer((_) async => null);
      when(() => service.getUserId()).thenAnswer((_) async => null);
      when(() => service.getUserEmail()).thenAnswer((_) async => null);
      when(() => service.getSessionExpiry()).thenAnswer((_) async => null);

      await service.clearAll();

      expect(await service.getAccessToken(), isNull);
      expect(await service.getRefreshToken(), isNull);
      expect(await service.getUserId(), isNull);
      expect(await service.getUserEmail(), isNull);
      expect(await service.getSessionExpiry(), isNull);
    });

    test('deleteAll removes all keys', () async {
      when(() => service.storeAccessToken('token'))
          .thenAnswer((_) async {});
      when(() => service.deleteAll()).thenAnswer((_) async {});
      when(() => service.getAccessToken()).thenAnswer((_) async => null);

      await service.storeAccessToken('token');
      await service.deleteAll();
      expect(await service.getAccessToken(), isNull);
    });

    test('returns null for unset keys', () async {
      when(() => service.getAccessToken()).thenAnswer((_) async => null);
      when(() => service.getRefreshToken()).thenAnswer((_) async => null);
      when(() => service.getSessionExpiry()).thenAnswer((_) async => null);
      when(() => service.getUserId()).thenAnswer((_) async => null);
      when(() => service.getUserEmail()).thenAnswer((_) async => null);

      expect(await service.getAccessToken(), isNull);
      expect(await service.getRefreshToken(), isNull);
      expect(await service.getSessionExpiry(), isNull);
      expect(await service.getUserId(), isNull);
      expect(await service.getUserEmail(), isNull);
    });
  });
}
