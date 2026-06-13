import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:threatlensia/features/reports/data/repositories/report_repository_impl.dart';
import 'package:threatlensia/features/reports/domain/entities/report.dart';
import 'package:threatlensia/features/threat_analysis/domain/repositories/threat_analysis_repository.dart';

import 'package:threatlensia/core/exceptions/app_exceptions.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockThreatAnalysisRepository extends Mock implements ThreatAnalysisRepository {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockThreatAnalysisRepository mockThreatAnalysisRepository;
  late ReportRepositoryImpl repository;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockThreatAnalysisRepository = MockThreatAnalysisRepository();
    
    repository = ReportRepositoryImpl(
      supabaseClient: mockSupabaseClient,
      threatAnalysisRepository: mockThreatAnalysisRepository,
    );
  });

  group('generateReport', () {
    test('throws NetworkException if format is not PDF', () async {
      expect(
        () => repository.generateReport(
          analysisId: '1',
          userId: 'user1',
          format: ReportFormat.json,
        ),
        throwsA(isA<NetworkException>()),
      );
    });

    test('throws NetworkException if analysis is not found', () async {
      when(() => mockThreatAnalysisRepository.getAnalysisById('1'))
          .thenAnswer((_) async => null);

      expect(
        () => repository.generateReport(
          analysisId: '1',
          userId: 'user1',
          format: ReportFormat.pdf,
        ),
        throwsA(isA<NetworkException>()),
      );
    });
    
    // Note: PDF generation testing would require mocktailing the pdf and path_provider
    // packages, which is generally outside unit test scope without heavy abstraction.
  });
}
