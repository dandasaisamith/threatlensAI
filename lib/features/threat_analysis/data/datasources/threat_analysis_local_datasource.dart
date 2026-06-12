import 'package:isar/isar.dart';

/// Local data source for threat analysis operations using Isar.
///
/// Provides offline-first capabilities for cached analyses.
/// All data is stored locally for offline access.
class ThreatAnalysisLocalDataSource {
  ThreatAnalysisLocalDataSource({required Isar isar}) : _isar = isar;

  final Isar _isar; // ignore: unused_field

  /// Save an analysis to local cache.
  Future<void> cacheAnalysis({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    // Isar schema implementation will be added when collections are defined.
  }

  /// Get a cached analysis by ID.
  Future<Map<String, dynamic>?> getCachedAnalysis(String id) async => null;

  /// Get all cached analyses for a user.
  Future<List<Map<String, dynamic>>> getCachedAnalyses(String userId) async =>
      [];

  /// Delete a cached analysis.
  Future<void> deleteCachedAnalysis(String id) async {
    // Will be implemented when Isar schemas are defined.
  }

  /// Clear all cached data (called on logout).
  Future<void> clearCache() async {
    // Will be implemented when Isar schemas are defined.
  }
}
