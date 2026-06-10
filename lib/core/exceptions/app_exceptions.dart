/// Base exception class for the application
/// 
/// All custom exceptions should extend this class
sealed class AppException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// Authentication related exceptions
/// 
/// Use when authentication operations fail
class AuthenticationException extends AppException {
  AuthenticationException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
        message: message,
        originalError: originalError,
        stackTrace: stackTrace,
      );
}

/// Network related exceptions
/// 
/// Use for HTTP/network failures
class NetworkException extends AppException {
  NetworkException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
        message: message,
        originalError: originalError,
        stackTrace: stackTrace,
      );
}

/// Database related exceptions
/// 
/// Use for Isar and database operations
class DatabaseException extends AppException {
  DatabaseException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
        message: message,
        originalError: originalError,
        stackTrace: stackTrace,
      );
}

/// AI API related exceptions
/// 
/// Use for DeepSeek API failures
class AiException extends AppException {
  AiException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
        message: message,
        originalError: originalError,
        stackTrace: stackTrace,
      );
}

/// Validation exceptions
/// 
/// Use for input validation failures
class ValidationException extends AppException {
  ValidationException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
        message: message,
        originalError: originalError,
        stackTrace: stackTrace,
      );
}

/// Generic application exception
/// 
/// Use for unspecified errors
class AppError extends AppException {
  AppError({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
        message: message,
        originalError: originalError,
        stackTrace: stackTrace,
      );
}
