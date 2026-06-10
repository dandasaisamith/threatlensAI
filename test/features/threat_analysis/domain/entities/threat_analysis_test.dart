import 'package:flutter_test/flutter_test.dart';
import 'package:threatlensia/features/threat_analysis/domain/entities/threat_analysis.dart';

void main() {
  group('ThreatAnalysis entity', () {
    test('creates with required fields', () {
      final analysis = ThreatAnalysis(
        id: '1',
        userId: 'user-1',
        systemDescription: 'A web application with login',
        assets: [],
        threats: [],
        status: AnalysisStatus.pending,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(analysis.id, '1');
      expect(analysis.userId, 'user-1');
      expect(analysis.systemDescription, 'A web application with login');
      expect(analysis.assets, isEmpty);
      expect(analysis.threats, isEmpty);
      expect(analysis.status, AnalysisStatus.pending);
      expect(analysis.riskScore, isNull);
    });

    test('creates with optional completedAt and riskScore', () {
      final analysis = ThreatAnalysis(
        id: '2',
        userId: 'user-1',
        systemDescription: 'API gateway',
        assets: [],
        threats: [],
        status: AnalysisStatus.completed,
        createdAt: DateTime(2024, 1, 1),
        completedAt: DateTime(2024, 1, 2),
        riskScore: 7.5,
      );

      expect(analysis.completedAt, DateTime(2024, 1, 2));
      expect(analysis.riskScore, 7.5);
    });
  });

  group('Asset', () {
    test('creates with all fields', () {
      final asset = Asset(
        id: 'a1',
        name: 'User Database',
        type: AssetType.data,
        description: 'PostgreSQL database with user credentials',
        sensitivity: AssetSensitivity.critical,
      );

      expect(asset.id, 'a1');
      expect(asset.name, 'User Database');
      expect(asset.type, AssetType.data);
      expect(asset.sensitivity, AssetSensitivity.critical);
    });
  });

  group('Threat', () {
    test('creates with default empty mitigations', () {
      final threat = Threat(
        id: 't1',
        name: 'SQL Injection',
        description: 'User input is not sanitized',
        strideCategory: StrideCategory.tampering,
        affectedAssets: ['a1'],
        dreadScore: DreadScore(
          damagePotential: 8,
          reproducibility: 9,
          exploitability: 7,
          affectedUsers: 6,
          discoverability: 5,
        ),
      );

      expect(threat.mitigations, isEmpty);
      expect(threat.strideCategory, StrideCategory.tampering);
    });
  });

  group('DreadScore', () {
    test('calculates average correctly', () {
      final score = DreadScore(
        damagePotential: 8,
        reproducibility: 8,
        exploitability: 8,
        affectedUsers: 8,
        discoverability: 8,
      );

      expect(score.average, 8.0);
    });

    test('calculates average with mixed values', () {
      final score = DreadScore(
        damagePotential: 10,
        reproducibility: 6,
        exploitability: 4,
        affectedUsers: 2,
        discoverability: 8,
      );

      expect(score.average, 6.0);
    });
  });

  group('Enums', () {
    test('StrideCategory has all 6 STRIDE categories', () {
      expect(StrideCategory.values.length, 6);
      expect(StrideCategory.values, contains(StrideCategory.spoofing));
      expect(StrideCategory.values, contains(StrideCategory.tampering));
      expect(StrideCategory.values, contains(StrideCategory.repudiation));
      expect(StrideCategory.values, contains(StrideCategory.informationDisclosure));
      expect(StrideCategory.values, contains(StrideCategory.denialOfService));
      expect(StrideCategory.values, contains(StrideCategory.elevationOfPrivilege));
    });

    test('AnalysisStatus covers all states', () {
      expect(AnalysisStatus.values.length, 4);
      expect(AnalysisStatus.values, contains(AnalysisStatus.pending));
      expect(AnalysisStatus.values, contains(AnalysisStatus.analyzing));
      expect(AnalysisStatus.values, contains(AnalysisStatus.completed));
      expect(AnalysisStatus.values, contains(AnalysisStatus.failed));
    });
  });
}
