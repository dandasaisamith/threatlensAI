import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

import '../../../../core/security/secure_storage_service.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';

// =============================================================================
// Infrastructure providers
// =============================================================================

/// Provides the DashboardRepository.
final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepositoryImpl(
    supabaseClient: Supabase.instance.client,
  ),
);

// =============================================================================
// State: Dashboard Stats
// =============================================================================

/// Manages the state of the dashboard statistics.
final dashboardStatsProvider =
    AsyncNotifierProvider<DashboardStatsNotifier, DashboardStats>(
  DashboardStatsNotifier.new,
);

class DashboardStatsNotifier extends AsyncNotifier<DashboardStats> {
  @override
  Future<DashboardStats> build() => _fetch();

  Future<DashboardStats> _fetch() async {
    final storage = GetIt.instance<SecureStorageService>();
    final userId = await storage.getUserId();

    if (userId == null || userId.isEmpty) {
      throw Exception('User is not authenticated.');
    }

    final repository = ref.read(dashboardRepositoryProvider);
    return repository.getDashboardStats(userId);
  }

  /// Force a refresh of the dashboard statistics.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}
