import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:threatlensia/features/auth/presentation/screens/login_screen.dart';
import 'package:threatlensia/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:threatlensia/features/threat_analysis/presentation/screens/threat_analysis_screen.dart';
import 'package:threatlensia/features/ai_chat/presentation/screens/ai_chat_screen.dart';
import 'package:threatlensia/features/reports/presentation/screens/reports_screen.dart';

/// GoRouter configuration provider
/// Defines all routes for the application
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
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
  );
});
