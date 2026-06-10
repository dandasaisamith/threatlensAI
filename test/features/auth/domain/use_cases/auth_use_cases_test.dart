import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:threatlensia/features/auth/domain/repositories/auth_repository.dart';
import 'package:threatlensia/features/auth/domain/use_cases/auth_use_cases.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  group('SignInUseCase', () {
    test('calls repository.signIn with correct parameters', () async {
      final useCase = SignInUseCase(repository: mockRepository);
      final expectedResult = AuthResult(
        user: const AuthUser(id: '1', email: 'test@example.com'),
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        expiresAt: DateTime(2024, 12, 31),
      );

      when(() => mockRepository.signIn(
            email: 'test@example.com',
            password: 'password123',
          )).thenAnswer((_) async => expectedResult);

      final result = await useCase.call(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, equals(expectedResult));
      verify(() => mockRepository.signIn(
            email: 'test@example.com',
            password: 'password123',
          )).called(1);
    });
  });

  group('SignUpUseCase', () {
    test('calls repository.signUp with correct parameters', () async {
      final useCase = SignUpUseCase(repository: mockRepository);
      final expectedResult = AuthResult(
        user: const AuthUser(id: '2', email: 'new@example.com'),
        accessToken: 'new-access-token',
        refreshToken: 'new-refresh-token',
        expiresAt: DateTime(2024, 12, 31),
      );

      when(() => mockRepository.signUp(
            email: 'new@example.com',
            password: 'securepass',
          )).thenAnswer((_) async => expectedResult);

      final result = await useCase.call(
        email: 'new@example.com',
        password: 'securepass',
      );

      expect(result, equals(expectedResult));
      verify(() => mockRepository.signUp(
            email: 'new@example.com',
            password: 'securepass',
          )).called(1);
    });
  });

  group('SignOutUseCase', () {
    test('calls repository.signOut', () async {
      final useCase = SignOutUseCase(repository: mockRepository);

      when(() => mockRepository.signOut()).thenAnswer((_) async {});

      await useCase.call();

      verify(() => mockRepository.signOut()).called(1);
    });
  });

  group('GetCurrentUserUseCase', () {
    test('returns user when authenticated', () async {
      final useCase = GetCurrentUserUseCase(repository: mockRepository);
      const user = AuthUser(id: '1', email: 'test@example.com');

      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => user);

      final result = await useCase.call();

      expect(result, equals(user));
    });

    test('returns null when not authenticated', () async {
      final useCase = GetCurrentUserUseCase(repository: mockRepository);

      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => null);

      final result = await useCase.call();

      expect(result, isNull);
    });
  });
}
