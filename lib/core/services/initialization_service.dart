import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/environment_config.dart';

/// Service responsible for initializing all core services on app startup
/// 
/// Handles:
/// - Isar database initialization
/// - Supabase setup
/// - PostHog analytics setup
/// 
/// Should be called once during app initialization in main()
class InitializationService {
  static late Isar _isar;
  static late Supabase _supabase;
  static late PostHog _posthog;

  static Isar get isar => _isar;
  static Supabase get supabase => _supabase;
  static PostHog get posthog => _posthog;

  /// Initialize all core services
  /// 
  /// Call this once during app startup before running the app
  /// 
  /// Throws exceptions if initialization fails
  static Future<void> initialize() async {
    // Initialize Isar Database
    await _initializeIsar();

    // Initialize Supabase
    await _initializeSupabase();

    // Initialize PostHog Analytics
    await _initializePostHog();
  }

  /// Initialize Isar local database
  static Future<void> _initializeIsar() async {
    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [
        // Add Isar collections here as they are created
        // Example:
        // ThreatAnalysisSchema,
        // AssetSchema,
        // ThreatSchema,
      ],
      directory: dir.path,
    );
  }

  /// Initialize Supabase for authentication and backend
  static Future<void> _initializeSupabase() async {
    _supabase = await Supabase.initialize(
      url: EnvironmentConfig.supabaseUrl,
      anonKey: EnvironmentConfig.supabaseAnonKey,
    );
  }

  /// Initialize PostHog for analytics
  static Future<void> _initializePostHog() async {
    await PostHog.enable();
    PostHog.setup(
      EnvironmentConfig.postHogApiKey,
      host: EnvironmentConfig.postHogApiHost,
    );
  }

  /// Dispose all services
  /// Call this during app shutdown
  static Future<void> dispose() async {
    await _isar.close();
    await PostHog.close();
  }
}
