import 'package:flutter_test/flutter_test.dart';
import 'package:threatlensia/features/threat_analysis/data/models/threat_analysis_model.dart';
import 'package:threatlensia/features/threat_analysis/domain/entities/threat_analysis.dart';

void main() {
  group('ThreatAnalysisModel.fromJson', () {
    // -------------------------------------------------------------------------
    // Minimal JSON
    // -------------------------------------------------------------------------

    test('parses minimal JSON with empty assets and threats', () {
      final json = <String, dynamic>{
        'id': 'a1',
        'user_id': 'u1',
        'system_description': 'A web app',
        'status': 'pending',
        'created_at': '2024-01-01T00:00:00.000Z',
        'assets': <dynamic>[],
        'threats': <dynamic>[],
      };

      final analysis = ThreatAnalysisModel.fromJson(json);

      expect(analysis.id, 'a1');
      expect(analysis.userId, 'u1');
      expect(analysis.systemDescription, 'A web app');
      expect(analysis.status, AnalysisStatus.pending);
      expect(analysis.assets, isEmpty);
      expect(analysis.threats, isEmpty);
      expect(analysis.riskScore, isNull);
      expect(analysis.completedAt, isNull);
    });

    // -------------------------------------------------------------------------
    // Full JSON with nested entities
    // -------------------------------------------------------------------------

    test('parses full JSON with assets, threats, mitigations, and DREAD', () {
      final json = <String, dynamic>{
        'id': 'a2',
        'user_id': 'u1',
        'system_description': 'API gateway with JWT auth',
        'status': 'completed',
        'risk_score': 7.5,
        'created_at': '2024-01-01T00:00:00.000Z',
        'completed_at': '2024-01-01T00:01:00.000Z',
        'assets': <dynamic>[
          <String, dynamic>{
            'id': 'asset1',
            'name': 'User Database',
            'type': 'data',
            'description': 'PostgreSQL DB with PII',
            'sensitivity': 'critical',
          },
          <String, dynamic>{
            'id': 'asset2',
            'name': 'Auth Service',
            'type': 'service',
            'description': 'JWT issuing service',
            'sensitivity': 'high',
          },
        ],
        'threats': <dynamic>[
          <String, dynamic>{
            'id': 'threat1',
            'name': 'SQL Injection',
            'description': 'Unsanitized user input reaches the DB query.',
            'stride_category': 'tampering',
            'affected_assets': <dynamic>['asset1'],
            'dread_score': <String, dynamic>{
              'damage_potential': 10,
              'reproducibility': 8,
              'exploitability': 7,
              'affected_users': 6,
              'discoverability': 4,
            },
            'mitigations': <dynamic>[
              <String, dynamic>{
                'id': 'm1',
                'description': 'Use parameterised queries.',
                'priority': 'critical',
                'implementation': 'Replace string concatenation with prepared statements.',
              },
            ],
          },
        ],
      };

      final analysis = ThreatAnalysisModel.fromJson(json);

      expect(analysis.status, AnalysisStatus.completed);
      expect(analysis.riskScore, 7.5);
      expect(analysis.completedAt, isNotNull);

      expect(analysis.assets.length, 2);
      expect(analysis.assets[0].name, 'User Database');
      expect(analysis.assets[0].type, AssetType.data);
      expect(analysis.assets[0].sensitivity, AssetSensitivity.critical);
      expect(analysis.assets[1].type, AssetType.service);
      expect(analysis.assets[1].sensitivity, AssetSensitivity.high);

      expect(analysis.threats.length, 1);
      final threat = analysis.threats.first;
      expect(threat.name, 'SQL Injection');
      expect(threat.strideCategory, StrideCategory.tampering);
      expect(threat.affectedAssets, contains('asset1'));

      expect(threat.dreadScore.damagePotential, 10);
      expect(threat.dreadScore.reproducibility, 8);
      expect(threat.dreadScore.exploitability, 7);
      expect(threat.dreadScore.affectedUsers, 6);
      expect(threat.dreadScore.discoverability, 4);
      // average = (10+8+7+6+4)/5 = 7.0
      expect(threat.dreadScore.average, 7.0);

      expect(threat.mitigations.length, 1);
      expect(threat.mitigations.first.priority, MitigationPriority.critical);
    });

    // -------------------------------------------------------------------------
    // Unknown enum values → safe defaults
    // -------------------------------------------------------------------------

    test('unknown status falls back to pending', () {
      final json = _minimalJson(overrides: {'status': 'unknown_xyz'});
      expect(ThreatAnalysisModel.fromJson(json).status, AnalysisStatus.pending);
    });

    test('unknown asset type falls back to data', () {
      final json = _minimalJson(
        overrides: {
          'assets': <dynamic>[
            _assetJson(overrides: {'type': 'magical_server'}),
          ],
        },
      );
      final analysis = ThreatAnalysisModel.fromJson(json);
      expect(analysis.assets.first.type, AssetType.data);
    });

    test('unknown asset sensitivity falls back to medium', () {
      final json = _minimalJson(
        overrides: {
          'assets': <dynamic>[
            _assetJson(overrides: {'sensitivity': 'ultra_secret'}),
          ],
        },
      );
      expect(
        ThreatAnalysisModel.fromJson(json).assets.first.sensitivity,
        AssetSensitivity.medium,
      );
    });

    test('unknown STRIDE category falls back to tampering', () {
      final json = _minimalJson(
        overrides: {
          'threats': <dynamic>[
            _threatJson(overrides: {'stride_category': 'unknown_cat'}),
          ],
        },
      );
      expect(
        ThreatAnalysisModel.fromJson(json).threats.first.strideCategory,
        StrideCategory.tampering,
      );
    });

    test('unknown mitigation priority falls back to medium', () {
      final json = _minimalJson(
        overrides: {
          'threats': <dynamic>[
            _threatJson(
              overrides: {
                'mitigations': <dynamic>[
                  _mitigationJson(overrides: {'priority': 'super_critical'}),
                ],
              },
            ),
          ],
        },
      );
      expect(
        ThreatAnalysisModel.fromJson(json).threats.first.mitigations.first.priority,
        MitigationPriority.medium,
      );
    });

    // -------------------------------------------------------------------------
    // All enum values round-trip
    // -------------------------------------------------------------------------

    test('all AnalysisStatus values are parsed correctly', () {
      const cases = {
        'pending': AnalysisStatus.pending,
        'analyzing': AnalysisStatus.analyzing,
        'completed': AnalysisStatus.completed,
        'failed': AnalysisStatus.failed,
      };
      for (final entry in cases.entries) {
        final json = _minimalJson(overrides: {'status': entry.key});
        expect(
          ThreatAnalysisModel.fromJson(json).status,
          entry.value,
          reason: 'status "${entry.key}"',
        );
      }
    });

    test('all StrideCategory values are parsed correctly', () {
      const cases = {
        'spoofing': StrideCategory.spoofing,
        'tampering': StrideCategory.tampering,
        'repudiation': StrideCategory.repudiation,
        'information_disclosure': StrideCategory.informationDisclosure,
        'denial_of_service': StrideCategory.denialOfService,
        'elevation_of_privilege': StrideCategory.elevationOfPrivilege,
      };
      for (final entry in cases.entries) {
        final json = _minimalJson(
          overrides: {
            'threats': <dynamic>[
              _threatJson(overrides: {'stride_category': entry.key}),
            ],
          },
        );
        expect(
          ThreatAnalysisModel.fromJson(json).threats.first.strideCategory,
          entry.value,
          reason: 'stride_category "${entry.key}"',
        );
      }
    });

    // -------------------------------------------------------------------------
    // Optional / null fields
    // -------------------------------------------------------------------------

    test('null assets field produces empty list', () {
      final json = _minimalJson(overrides: {'assets': null});
      expect(ThreatAnalysisModel.fromJson(json).assets, isEmpty);
    });

    test('null threats field produces empty list', () {
      final json = _minimalJson(overrides: {'threats': null});
      expect(ThreatAnalysisModel.fromJson(json).threats, isEmpty);
    });

    test('null mitigations field produces empty list', () {
      final json = _minimalJson(
        overrides: {
          'threats': <dynamic>[
            _threatJson(overrides: {'mitigations': null}),
          ],
        },
      );
      expect(
        ThreatAnalysisModel.fromJson(json).threats.first.mitigations,
        isEmpty,
      );
    });

    test('missing dread_score uses default values of 5', () {
      final json = _minimalJson(
        overrides: {
          'threats': <dynamic>[
            _threatJson(overrides: {'dread_score': null}),
          ],
        },
      );
      final dread = ThreatAnalysisModel.fromJson(json).threats.first.dreadScore;
      expect(dread.damagePotential, 5);
      expect(dread.reproducibility, 5);
      expect(dread.exploitability, 5);
      expect(dread.affectedUsers, 5);
      expect(dread.discoverability, 5);
      expect(dread.average, 5.0);
    });
  });
}

// =============================================================================
// Test helpers
// =============================================================================

/// Builds a minimal valid analysis JSON, applying [overrides] on top.
Map<String, dynamic> _minimalJson({Map<String, dynamic> overrides = const {}}) {
  final base = <String, dynamic>{
    'id': 'test-id',
    'user_id': 'test-user',
    'system_description': 'A test system',
    'status': 'pending',
    'created_at': '2024-06-01T00:00:00.000Z',
    'assets': <dynamic>[],
    'threats': <dynamic>[],
  };
  return {...base, ...overrides};
}

/// Builds a minimal valid asset JSON, applying [overrides] on top.
Map<String, dynamic> _assetJson({Map<String, dynamic> overrides = const {}}) {
  final base = <String, dynamic>{
    'id': 'asset-id',
    'name': 'Test Asset',
    'type': 'data',
    'description': 'A test asset',
    'sensitivity': 'medium',
  };
  return {...base, ...overrides};
}

/// Builds a minimal valid threat JSON, applying [overrides] on top.
Map<String, dynamic> _threatJson({Map<String, dynamic> overrides = const {}}) {
  final base = <String, dynamic>{
    'id': 'threat-id',
    'name': 'Test Threat',
    'description': 'A test threat',
    'stride_category': 'tampering',
    'affected_assets': <dynamic>[],
    'dread_score': <String, dynamic>{
      'damage_potential': 5,
      'reproducibility': 5,
      'exploitability': 5,
      'affected_users': 5,
      'discoverability': 5,
    },
    'mitigations': <dynamic>[],
  };
  return {...base, ...overrides};
}

/// Builds a minimal valid mitigation JSON, applying [overrides] on top.
Map<String, dynamic> _mitigationJson({
  Map<String, dynamic> overrides = const {},
}) {
  final base = <String, dynamic>{
    'id': 'mit-id',
    'description': 'A mitigation',
    'priority': 'medium',
    'implementation': 'Do this.',
  };
  return {...base, ...overrides};
}
