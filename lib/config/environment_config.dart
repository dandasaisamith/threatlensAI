import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration class for environment variables
/// Loads and validates all required environment variables on app startup
class EnvironmentConfig {
  static late final String supabaseUrl;
  static late final String supabaseAnonKey;
  static late final String deepseekApiKey;
  static late final String deepseekApiBaseUrl;
  static late final String postHogApiKey;
  static late final String postHogApiHost;
  static late final String sentryDsn;
  static late final String environment;
  static late final bool isDebug;

  /// Initialize environment configuration from .env file
  /// 
  /// Throws [Exception] if required variables are missing
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');

    supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    deepseekApiKey = dotenv.env['DEEPSEEK_API_KEY'] ?? '';
    deepseekApiBaseUrl =
        dotenv.env['DEEPSEEK_API_BASE_URL'] ?? 'https://api.deepseek.com/v1';
    postHogApiKey = dotenv.env['POSTHOG_API_KEY'] ?? '';
    postHogApiHost =
        dotenv.env['POSTHOG_API_HOST'] ?? 'https://us.posthog.com';
    sentryDsn = dotenv.env['SENTRY_DSN'] ?? '';
    environment = dotenv.env['APP_ENV'] ?? 'development';
    isDebug = dotenv.env['DEBUG_MODE'] == 'true';

    _validateRequiredConfigs();
  }

  /// Validate that all required configuration values are present
  static void _validateRequiredConfigs() {
    final required = [
      ('SUPABASE_URL', supabaseUrl),
      ('SUPABASE_ANON_KEY', supabaseAnonKey),
      ('DEEPSEEK_API_KEY', deepseekApiKey),
    ];

    for (final (key, value) in required) {
      if (value.isEmpty) {
        throw Exception('Missing required environment variable: \$key');
      }
    }
  }
}
