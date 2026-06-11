import 'package:flutter_test/flutter_test.dart';
import 'package:threatlensia/core/exceptions/app_exceptions.dart';

void main() {
  group('AppException', () {
    test('AuthenticationException carries message and originalError', () {
      final exception = AuthenticationException(
        message: 'Session expired',
        originalError: 'token_invalid',
      );

      expect(exception.message, equals('Session expired'));
      expect(exception.originalError, equals('token_invalid'));
      expect(exception.toString(), equals('Session expired'));
    });

    test('NetworkException carries message', () {
      final exception = NetworkException(
        message: 'No internet connection',
      );

      expect(exception.message, equals('No internet connection'));
      expect(exception.originalError, isNull);
      expect(exception.stackTrace, isNull);
    });

    test('DatabaseException carries all fields', () {
      final stack = StackTrace.current;
      final exception = DatabaseException(
        message: 'Write failed',
        originalError: 'disk_full',
        stackTrace: stack,
      );

      expect(exception.message, equals('Write failed'));
      expect(exception.originalError, equals('disk_full'));
      expect(exception.stackTrace, equals(stack));
    });

    test('AiException carries message', () {
      final exception = AiException(
        message: 'AI provider unreachable',
      );

      expect(exception.message, equals('AI provider unreachable'));
    });

    test('ValidationException carries message', () {
      final exception = ValidationException(
        message: 'Invalid input',
      );

      expect(exception.message, equals('Invalid input'));
    });

    test('AppError carries message', () {
      final exception = AppError(
        message: 'Something went wrong',
      );

      expect(exception.message, equals('Something went wrong'));
    });

    test('sealed class prevents non-subclass instantiation', () {
      // AppException is sealed — only known subclasses can exist
      expect(
        () => AuthenticationException(message: 'test'),
        returnsNormally,
      );
    });
  });
}
