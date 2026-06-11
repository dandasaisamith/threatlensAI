import 'package:flutter_test/flutter_test.dart';
import 'package:threatlensia/features/reports/domain/entities/report.dart';

void main() {
  group('Report entity', () {
    test('creates with required fields', () {
      final report = Report(
        id: 'rpt-1',
        analysisId: 'analysis-1',
        userId: 'user-1',
        title: 'Threat Analysis Report',
        generatedAt: DateTime(2024, 6, 10),
        format: ReportFormat.pdf,
      );

      expect(report.id, 'rpt-1');
      expect(report.analysisId, 'analysis-1');
      expect(report.userId, 'user-1');
      expect(report.title, 'Threat Analysis Report');
      expect(report.format, ReportFormat.pdf);
      expect(report.filePath, isNull);
      expect(report.fileSizeBytes, isNull);
    });

    test('creates with optional file info', () {
      final report = Report(
        id: 'rpt-2',
        analysisId: 'analysis-1',
        userId: 'user-1',
        title: 'Report',
        generatedAt: DateTime(2024, 6, 10),
        format: ReportFormat.json,
        filePath: '/tmp/report.json',
        fileSizeBytes: 1024,
      );

      expect(report.filePath, '/tmp/report.json');
      expect(report.fileSizeBytes, 1024);
    });

    test('ReportFormat enum covers all formats', () {
      expect(ReportFormat.values.length, 3);
      expect(ReportFormat.values, contains(ReportFormat.pdf));
      expect(ReportFormat.values, contains(ReportFormat.json));
      expect(ReportFormat.values, contains(ReportFormat.markdown));
    });
  });
}
