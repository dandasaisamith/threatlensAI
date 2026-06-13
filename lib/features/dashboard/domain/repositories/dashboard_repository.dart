import '../entities/dashboard_stats.dart';

/// Repository interface for Dashboard-related data access.
abstract class DashboardRepository {
  /// Fetches aggregated dashboard statistics for a specific user.
  Future<DashboardStats> getDashboardStats(String userId);
}
