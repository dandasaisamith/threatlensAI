import '../repositories/auth_repository.dart';

/// Use case for signing in a user.
///
/// Encapsulates the business logic for authentication.
/// Domain layer has no framework dependencies.
class SignInUseCase {
  SignInUseCase({required AuthRepository repository})
      : _repository = repository;

  final AuthRepository _repository;

  Future<AuthResult> call({required String email, required String password}) {
    return _repository.signIn(email: email, password: password);
  }
}

/// Use case for signing up a new user.
class SignUpUseCase {
  SignUpUseCase({required AuthRepository repository})
      : _repository = repository;

  final AuthRepository _repository;

  Future<AuthResult> call({required String email, required String password}) {
    return _repository.signUp(email: email, password: password);
  }
}

/// Use case for signing out.
class SignOutUseCase {
  SignOutUseCase({required AuthRepository repository})
      : _repository = repository;

  final AuthRepository _repository;

  Future<void> call() => _repository.signOut();
}

/// Use case for getting the current user.
class GetCurrentUserUseCase {
  GetCurrentUserUseCase({required AuthRepository repository})
      : _repository = repository;

  final AuthRepository _repository;

  Future<AuthUser?> call() => _repository.getCurrentUser();
}
