import '../entities/threat_analysis.dart';

/// Repository interface for threat analysis operations.
///
/// Domain layer rules:
/// - No Flutter imports
/// - No Dio imports
/// - No Supabase imports
abstract class ThreatAnalysisRepository {
  /// Create a new threat analysis from a system description.
  Future<ThreatAnalysis> createAnalysis({
    required String userId,
    required String systemDescription,
  });

  /// Get an analysis by ID.
  Future<ThreatAnalysis?> getAnalysisById(String id);

  /// Get all analyses for a user.
  Future<List<ThreatAnalysis>> getAnalysesByUser(String userId);

  /// Update an existing analysis.
  Future<ThreatAnalysis> updateAnalysis(ThreatAnalysis analysis);

  /// Delete an analysis.
  Future<void> deleteAnalysis(String id);

  /// Stream of analysis updates (for real-time progress).
  Stream<ThreatAnalysis> watchAnalysis(String id);
}
