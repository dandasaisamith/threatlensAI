import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/environment_config.dart';
import '../network/api_client.dart';
import '../security/secure_storage_service.dart';
import '../security/session_manager.dart';
import '../security/logout_wiper.dart';

/// Service responsible for initializing all core services on app startup.
class InitializationService {
  static late Isar _isar;
  static late SupabaseClient _supabaseClient;
  static late SecureStorageService _secureStorage;
  static late SessionManager _sessionManager;
  static late ApiClient _apiClient;
  static late LogoutWiper _logoutWiper;

  static Isar get isar => _isar;
  static SupabaseClient get supabaseClient => _supabaseClient;
  static SecureStorageService get secureStorage => _secureStorage;
  static SessionManager get sessionManager => _sessionManager;
  static ApiClient get apiClient => _apiClient;
  static LogoutWiper get logoutWiper => _logoutWiper;

  static Future<void> initialize() async {
    _secureStorage = SecureStorageService();
    await _initializeSupabase();
    _sessionManager = SessionManager(
      secureStorage: _secureStorage,
      supabase: _supabaseClient,
    );
    _apiClient = ApiClient(secureStorage: _secureStorage);
    _logoutWiper = LogoutWiper(
      secureStorage: _secureStorage,
      sessionManager: _sessionManager,
      supabase: _supabaseClient,
    );
    await _initializeIsar();
    await _initializePostHog();
    await _sessionManager.initialize();
    _registerServices();
  }

  static Future<void> _initializeIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([], directory: dir.path);
  }

  static Future<void> _initializeSupabase() async {
    final supabase = await Supabase.initialize(
      url: EnvironmentConfig.supabaseUrl,
      anonKey: EnvironmentConfig.supabaseAnonKey,
    );
    _supabaseClient = supabase.client;
  }

  static Future<void> _initializePostHog() async {
    // Posthog v3.3.0: setup() was removed, use enable() to start tracking
    // API key is configured via native platform (AndroidManifest.xml / Info.plist)
    await Posthog().enable();
  }

  static void _registerServices() {
    final sl = GetIt.instance;
    if (!sl.isRegistered<SecureStorageService>()) {
      sl.registerSingleton<SecureStorageService>(_secureStorage);
    }
    if (!sl.isRegistered<SessionManager>()) {
      sl.registerSingleton<SessionManager>(_sessionManager);
    }
    if (!sl.isRegistered<ApiClient>()) {
      sl.registerSingleton<ApiClient>(_apiClient);
    }
    if (!sl.isRegistered<LogoutWiper>()) {
      sl.registerSingleton<LogoutWiper>(_logoutWiper);
    }
  }

  static Future<void> dispose() async {
    try { _sessionManager.dispose(); } catch (_) {}
    try { await _isar.close(); } catch (_) {}
  }
}
