import '../entities/report.dart';

/// Repository interface for report operations.
///
/// Domain layer rules:
/// - No Flutter imports
/// - No Dio imports
/// - No Supabase imports
abstract class ReportRepository {
  /// Generate a report from an analysis.
  Future<Report> generateReport({
    required String analysisId,
    required String userId,
    required ReportFormat format,
  });

  /// Get all reports for a user.
  Future<List<Report>> getReportsByUser(String userId);

  /// Get a report by ID.
  Future<Report?> getReportById(String id);

  /// Delete a report.
  Future<void> deleteReport(String id);

  /// Export report to a shareable file.
  Future<String> exportReport(String reportId);
}
