import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/security/session_manager.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/threat_analysis/presentation/screens/threat_analysis_screen.dart';
import '../features/ai_chat/presentation/screens/ai_chat_screen.dart';
import '../features/reports/presentation/screens/reports_screen.dart';

/// GoRouter configuration with auth guard redirect logic.
///
/// Security:
/// - Unauthenticated users can only access /login
/// - Authenticated users cannot access /login (redirected to dashboard)
/// - All protected routes require authentication
/// - No protected screen is reachable without authentication
final goRouterProvider = Provider<GoRouter>((ref) {
  final sessionManager = ref.watch(sessionManagerProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: sessionManager,
    redirect: (context, state) {
      final isAuthed =
          sessionManager.currentState == SessionState.authenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      // Unauthenticated: only allow login
      if (!isAuthed && !isLoginRoute) {
        return '/login';
      }

      // Authenticated: redirect away from login to dashboard
      if (isAuthed && isLoginRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
        routes: [
          GoRoute(
            path: 'threat-analysis',
            name: 'threat-analysis',
            builder: (context, state) => const ThreatAnalysisScreen(),
          ),
          GoRoute(
            path: 'ai-chat/:analysisId',
            name: 'ai-chat',
            builder: (context, state) => AiChatScreen(
              analysisId: state.pathParameters['analysisId'] ?? '',
            ),
          ),
          GoRoute(
            path: 'reports',
            name: 'reports',
            builder: (context, state) => const ReportsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error?.toString()}'),
      ),
    ),
  );
});

/// Provider for the session manager used by the router.
final sessionManagerProvider = Provider<SessionManager>((ref) {
  throw UnimplementedError(
    'sessionManagerProvider must be overridden at app startup',
  );
});
