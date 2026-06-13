/// Configuration class for environment variables.
///
/// Loads and validates all required environment variables on app startup.
///
/// Security: No AI provider secrets (DeepSeek, OpenAI, Claude) are stored
/// in the mobile client. All AI requests flow through Supabase Edge Functions
/// which own and manage provider credentials server-side.
class EnvironmentConfig {
  static late final String supabaseUrl;
  static late final String supabaseAnonKey;
  static late final String postHogApiKey;
  static late final String postHogApiHost;
  static late final String sentryDsn;
  static late final String environment;
  static late final bool isDebug;

  /// The base URL for Supabase Edge Functions that proxy AI requests.
  /// Mobile app communicates only with this endpoint — never with AI providers directly.
  static late final String edgeFunctionBaseUrl;

  /// Initialize environment configuration from compile-time variables.
  ///
  /// Throws [Exception] if required variables are missing.
  static Future<void> initialize() async {
    supabaseUrl = const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    postHogApiKey = const String.fromEnvironment('POSTHOG_API_KEY', defaultValue: '');
    postHogApiHost = const String.fromEnvironment('POSTHOG_API_HOST', defaultValue: 'https://us.posthog.com');
    sentryDsn = const String.fromEnvironment('SENTRY_DSN', defaultValue: '');
    environment = const String.fromEnvironment('APP_ENV', defaultValue: 'development');
    isDebug = const String.fromEnvironment('DEBUG_MODE', defaultValue: '') == 'true';

    // Edge Function base URL defaults to the Supabase project URL
    edgeFunctionBaseUrl = const String.fromEnvironment('EDGE_FUNCTION_BASE_URL', defaultValue: '');
    if (edgeFunctionBaseUrl.isEmpty && supabaseUrl.isNotEmpty) {
      edgeFunctionBaseUrl = '$supabaseUrl/functions/v1';
    }

    _validateRequiredConfigs();
  }

  /// Validate that all required configuration values are present.
  static void _validateRequiredConfigs() {
    final required = [
      ('SUPABASE_URL', supabaseUrl),
      ('SUPABASE_ANON_KEY', supabaseAnonKey),
    ];

    for (final (key, value) in required) {
      if (value.isEmpty) {
        throw Exception('Missing required environment variable: $key');
      }
    }
  }
}
