import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'config/environment_config.dart';
import 'config/router.dart';
import 'core/services/initialization_service.dart';

/// Application entry point
///
/// Initializes:
/// - Environment configuration
/// - Core services (Isar, Supabase, secure storage)
/// - Error tracking (Sentry)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize configuration
  await EnvironmentConfig.initialize();

  // Initialize core services
  await InitializationService.initialize();

  final app = ProviderScope(
    overrides: [
      // Override sessionManagerProvider with the initialized instance
      sessionManagerProvider.overrideWithValue(
        InitializationService.sessionManager,
      ),
    ],
    child: const ThreatLensAIApp(),
  );

  // Initialize Sentry only when DSN is not empty
  if (EnvironmentConfig.sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = EnvironmentConfig.sentryDsn;
        options.environment = EnvironmentConfig.environment;
        // Higher sample rate in debug mode
        options.tracesSampleRate = EnvironmentConfig.isDebug ? 1.0 : 0.1;
        // Don't capture events in debug mode by default
        options.debug = EnvironmentConfig.isDebug;
      },
      appRunner: () => runApp(app),
    );
  } else {
    runApp(app);
  }
}

/// Root widget for the ThreatLens AI application
class ThreatLensAIApp extends ConsumerWidget {
  const ThreatLensAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'ThreatLens AI',
      theme: _buildTheme(),
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }

  /// Build the application theme
  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1F2937),
        brightness: Brightness.dark,
      ),
      fontFamily: 'GoogleSans',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFF1F2937),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      scaffoldBackgroundColor: const Color(0xFF111827),
      cardTheme: CardThemeData(
        elevation: 1,
        color: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
