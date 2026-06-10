import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'session_manager.dart';

/// Provides auth guard redirect logic for GoRouter.
///
/// Intercepts all navigation and redirects based on authentication state:
/// - Unauthenticated users can only access `/login`
/// - Authenticated users cannot access `/login` (redirected to dashboard)
/// - Protected routes require authentication
///
/// This is the single source of truth for route authorization.
/// Used by router.dart in the `redirect:` callback.
class AuthGuard {
  AuthGuard({required this.sessionManager});

  final SessionManager sessionManager;

  /// GoRouter redirect function.
  ///
  /// Returns the redirect path, or null to allow normal navigation.
  /// Matches GoRouter's redirect signature: `String? Function(BuildContext, GoRouterState)`
  String? redirect(BuildContext context, GoRouterState state) {
    final isAuthed = sessionManager.currentState == SessionState.authenticated;
    final isLoginRoute = state.matchedLocation == '/login';

    // Unauthenticated: only allow login
    if (!isAuthed && !isLoginRoute) {
      return '/login';
    }

    // Authenticated: redirect away from login to dashboard
    if (isAuthed && isLoginRoute) {
      return '/';
    }

    // Allow navigation
    return null;
  }
}
