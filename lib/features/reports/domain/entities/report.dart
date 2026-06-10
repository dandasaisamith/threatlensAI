/// Domain entity for a generated threat report.
///
/// Pure domain model — no framework dependencies.
class Report {
  const Report({
    required this.id,
    required this.analysisId,
    required this.userId,
    required this.title,
    required this.generatedAt,
    required this.format,
    this.filePath,
    this.fileSizeBytes,
  });

  final String id;
  final String analysisId;
  final String userId;
  final String title;
  final DateTime generatedAt;
  final ReportFormat format;
  final String? filePath;
  final int? fileSizeBytes;
}

/// Supported report formats.
enum ReportFormat {
  pdf,
  json,
  markdown,
}
