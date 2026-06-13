import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:threatlensia/core/security/secure_storage_service.dart';
import 'package:threatlensia/features/reports/domain/entities/report.dart';
import 'package:threatlensia/features/reports/domain/repositories/report_repository.dart';
import 'package:threatlensia/features/reports/presentation/providers/report_providers.dart';

class MockReportRepository extends Mock implements ReportRepository {}
class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockReportRepository mockRepository;
  late MockSecureStorageService mockStorage;

  setUp(() {
    mockRepository = MockReportRepository();
    mockStorage = MockSecureStorageService();

    if (GetIt.instance.isRegistered<SecureStorageService>()) {
      GetIt.instance.unregister<SecureStorageService>();
    }
    GetIt.instance.registerSingleton<SecureStorageService>(mockStorage);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        reportRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('reportListProvider', () {
    test('fetches reports successfully', () async {
      final container = createContainer();

      when(() => mockStorage.getUserId()).thenAnswer((_) async => 'user-123');
      
      final mockReports = [
        Report(
          id: 'report-1',
          analysisId: 'analysis-1',
          userId: 'user-123',
          title: 'Test Report',
          generatedAt: DateTime.now(),
          format: ReportFormat.pdf,
          filePath: '/path/to/report.pdf',
          fileSizeBytes: 1024,
        ),
      ];
      
      when(() => mockRepository.getReportsByUser('user-123'))
          .thenAnswer((_) async => mockReports);

      expect(
        container.read(reportListProvider),
        const AsyncValue<List<Report>>.loading(),
      );

      final result = await container.read(reportListProvider.future);

      expect(result, equals(mockReports));
      verify(() => mockStorage.getUserId()).called(1);
      verify(() => mockRepository.getReportsByUser('user-123')).called(1);
    });

    test('emits error if user is not authenticated', () async {
      final container = createContainer();

      when(() => mockStorage.getUserId()).thenAnswer((_) async => null);

      final result = await container.read(reportListProvider.future);

      expect(result, isEmpty);
      verify(() => mockStorage.getUserId()).called(1);
      verifyNever(() => mockRepository.getReportsByUser(any()));
    });
  });

  group('generateReportProvider', () {
    test('generates report successfully', () async {
      final container = createContainer();

      when(() => mockStorage.getUserId()).thenAnswer((_) async => 'user-123');
      
      final mockReport = Report(
        id: 'report-1',
        analysisId: 'analysis-1',
        userId: 'user-123',
        title: 'Test Report',
        generatedAt: DateTime.now(),
        format: ReportFormat.pdf,
        filePath: '/path/to/report.pdf',
        fileSizeBytes: 1024,
      );
      
      when(() => mockRepository.generateReport(
        analysisId: 'analysis-1',
        userId: 'user-123',
        format: ReportFormat.pdf,
      )).thenAnswer((_) async => mockReport);

      // We need to mock getReportsByUser because addReport modifies reportListProvider state
      when(() => mockRepository.getReportsByUser('user-123')).thenAnswer((_) async => []);

      // Trigger the action
      await container.read(generateReportProvider.notifier).generateReport('analysis-1');

      final state = container.read(generateReportProvider);
      expect(state, isA<GenerateReportSuccess>());
      expect((state as GenerateReportSuccess).report, mockReport);
    });
  });
}
