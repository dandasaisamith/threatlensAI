import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/security/secure_storage_service.dart';
import '../../../../core/security/session_manager.dart';
import '../../../../core/services/initialization_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/use_cases/auth_use_cases.dart';

/// Provides the AuthRepository implementation.
/// Injects required dependencies from GetIt/InitializationService.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    supabase: InitializationService.supabaseClient,
    secureStorage: GetIt.instance<SecureStorageService>(),
    sessionManager: GetIt.instance<SessionManager>(),
  );
});

/// Exposes the current auth state stream from the repository.
final authStateProvider = StreamProvider<AuthUser?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

// -----------------------------------------------------------------------------
// Use Case Providers
// -----------------------------------------------------------------------------

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(repository: ref.watch(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(repository: ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(repository: ref.watch(authRepositoryProvider));
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(repository: ref.watch(authRepositoryProvider));
});

// -----------------------------------------------------------------------------
// UI State Controllers
// -----------------------------------------------------------------------------

/// Controller for Login Screen state.
final loginControllerProvider =
    AsyncNotifierProvider.autoDispose<LoginController, void>(
  LoginController.new,
);

class LoginController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state is idle (null)
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(signInUseCaseProvider);
      await useCase(email: email, password: password);
    });
  }
}

/// Controller for Sign Up Screen state.
final signUpControllerProvider =
    AsyncNotifierProvider.autoDispose<SignUpController, void>(
  SignUpController.new,
);

class SignUpController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state is idle (null)
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(signUpUseCaseProvider);
      await useCase(email: email, password: password);
    });
  }
}

/// Controller for Reset Password Screen state.
final resetPasswordControllerProvider =
    AsyncNotifierProvider.autoDispose<ResetPasswordController, void>(
  ResetPasswordController.new,
);

class ResetPasswordController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state is idle (null)
  }

  Future<void> sendResetEmail(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(resetPasswordUseCaseProvider);
      await useCase(email: email);
    });
  }
}
