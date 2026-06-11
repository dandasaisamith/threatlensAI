import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:threatlensia/features/threat_analysis/domain/entities/threat_analysis.dart';
import 'package:threatlensia/features/threat_analysis/domain/repositories/threat_analysis_repository.dart';
import 'package:threatlensia/features/threat_analysis/domain/use_cases/threat_analysis_use_cases.dart';

class MockThreatAnalysisRepository extends Mock
    implements ThreatAnalysisRepository {}

void main() {
  late MockThreatAnalysisRepository mockRepository;

  setUp(() {
    mockRepository = MockThreatAnalysisRepository();
  });

  group('CreateAnalysisUseCase', () {
    test('calls repository.createAnalysis with correct parameters', () async {
      final useCase = CreateAnalysisUseCase(repository: mockRepository);
      final expectedAnalysis = ThreatAnalysis(
        id: 'a1',
        userId: 'user-1',
        systemDescription: 'Web app with login',
        assets: [],
        threats: [],
        status: AnalysisStatus.pending,
        createdAt: DateTime(2024, 6, 10),
      );

      when(() => mockRepository.createAnalysis(
            userId: 'user-1',
            systemDescription: 'Web app with login',
          )).thenAnswer((_) async => expectedAnalysis);

      final result = await useCase.call(
        userId: 'user-1',
        systemDescription: 'Web app with login',
      );

      expect(result, equals(expectedAnalysis));
      verify(() => mockRepository.createAnalysis(
            userId: 'user-1',
            systemDescription: 'Web app with login',
          )).called(1);
    });
  });

  group('GetAnalysisByIdUseCase', () {
    test('returns analysis when found', () async {
      final useCase = GetAnalysisByIdUseCase(repository: mockRepository);
      final analysis = ThreatAnalysis(
        id: 'a1',
        userId: 'user-1',
        systemDescription: 'API',
        assets: [],
        threats: [],
        status: AnalysisStatus.completed,
        createdAt: DateTime(2024, 6, 10),
      );

      when(() => mockRepository.getAnalysisById('a1'))
          .thenAnswer((_) async => analysis);

      final result = await useCase.call('a1');

      expect(result, equals(analysis));
    });

    test('returns null when not found', () async {
      final useCase = GetAnalysisByIdUseCase(repository: mockRepository);

      when(() => mockRepository.getAnalysisById('nonexistent'))
          .thenAnswer((_) async => null);

      final result = await useCase.call('nonexistent');

      expect(result, isNull);
    });
  });

  group('GetAnalysesByUserUseCase', () {
    test('returns list of analyses for user', () async {
      final useCase = GetAnalysesByUserUseCase(repository: mockRepository);
      final analyses = [
        ThreatAnalysis(
          id: 'a1',
          userId: 'user-1',
          systemDescription: 'Web app',
          assets: [],
          threats: [],
          status: AnalysisStatus.completed,
          createdAt: DateTime(2024, 6, 10),
        ),
      ];

      when(() => mockRepository.getAnalysesByUser('user-1'))
          .thenAnswer((_) async => analyses);

      final result = await useCase.call('user-1');

      expect(result.length, 1);
      expect(result.first.id, 'a1');
    });
  });

  group('DeleteAnalysisUseCase', () {
    test('calls repository.deleteAnalysis', () async {
      final useCase = DeleteAnalysisUseCase(repository: mockRepository);

      when(() => mockRepository.deleteAnalysis('a1'))
          .thenAnswer((_) async {});

      await useCase.call('a1');

      verify(() => mockRepository.deleteAnalysis('a1')).called(1);
    });
  });
}
