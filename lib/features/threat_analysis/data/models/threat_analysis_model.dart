import '../../domain/entities/threat_analysis.dart';

/// Maps raw API JSON (from Supabase Edge Functions) to domain entities.
///
/// Lives in the data layer — the domain layer has zero dependency on this class.
/// All enum-parsing methods fall back to a safe default for unknown strings so
/// that API schema evolution never crashes the client.
class ThreatAnalysisModel {
  const ThreatAnalysisModel._();

  /// Parse a full [ThreatAnalysis] from an Edge Function JSON response.
  static ThreatAnalysis fromJson(Map<String, dynamic> json) => ThreatAnalysis(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        systemDescription: json['system_description'] as String,
        assets: _parseAssets(json['assets']),
        threats: _parseThreats(json['threats']),
        status: _parseStatus(json['status'] as String? ?? 'pending'),
        createdAt: DateTime.parse(json['created_at'] as String),
        completedAt: json['completed_at'] != null
            ? DateTime.tryParse(json['completed_at'] as String)
            : null,
        riskScore: (json['risk_score'] as num?)?.toDouble(),
      );

  // ---------------------------------------------------------------------------
  // Assets
  // ---------------------------------------------------------------------------

  static List<Asset> _parseAssets(dynamic raw) {
    if (raw == null) return const [];
    return (raw as List<dynamic>)
        .map((e) => _parseAsset(e as Map<String, dynamic>))
        .toList();
  }

  static Asset _parseAsset(Map<String, dynamic> json) => Asset(
        id: json['id'] as String,
        name: json['name'] as String,
        type: _parseAssetType(json['type'] as String? ?? 'data'),
        description: json['description'] as String? ?? '',
        sensitivity: _parseAssetSensitivity(
          json['sensitivity'] as String? ?? 'medium',
        ),
      );

  // ---------------------------------------------------------------------------
  // Threats
  // ---------------------------------------------------------------------------

  static List<Threat> _parseThreats(dynamic raw) {
    if (raw == null) return const [];
    return (raw as List<dynamic>)
        .map((e) => _parseThreat(e as Map<String, dynamic>))
        .toList();
  }

  static Threat _parseThreat(Map<String, dynamic> json) => Threat(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        strideCategory: _parseStrideCategory(
          json['stride_category'] as String? ?? 'tampering',
        ),
        affectedAssets: (json['affected_assets'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        dreadScore: _parseDreadScore(
          json['dread_scores'] ?? json['dread_score'] ?? const <String, dynamic>{},
        ),
        mitigations: _parseMitigations(json['mitigations']),
      );

  static DreadScore _parseDreadScore(dynamic raw) {
    Map<String, dynamic> json = {};
    if (raw is List) {
      if (raw.isNotEmpty) {
        json = raw.first as Map<String, dynamic>;
      }
    } else if (raw is Map) {
      json = raw as Map<String, dynamic>;
    }
    
    return DreadScore(
      damagePotential: (json['damage_potential'] ?? json['damage'] as num?)?.toInt() ?? 5,
      reproducibility: (json['reproducibility'] as num?)?.toInt() ?? 5,
      exploitability: (json['exploitability'] as num?)?.toInt() ?? 5,
      affectedUsers: (json['affected_users'] ?? json['affectedUsers'] as num?)?.toInt() ?? 5,
      discoverability: (json['discoverability'] as num?)?.toInt() ?? 5,
    );
  }

  static List<Mitigation> _parseMitigations(dynamic raw) {
    if (raw == null) return const [];
    return (raw as List<dynamic>)
        .map((e) => _parseMitigation(e as Map<String, dynamic>))
        .toList();
  }

  static Mitigation _parseMitigation(Map<String, dynamic> json) => Mitigation(
        id: json['id'] as String,
        description: json['description'] as String? ?? '',
        priority: _parseMitigationPriority(
          json['priority'] as String? ?? 'medium',
        ),
        implementation: json['implementation'] as String? ?? '',
      );

  // ---------------------------------------------------------------------------
  // Enum parsers — unknown values fall back to safe defaults
  // ---------------------------------------------------------------------------

  static AnalysisStatus _parseStatus(String raw) => switch (raw) {
        'analyzing' => AnalysisStatus.analyzing,
        'completed' => AnalysisStatus.completed,
        'failed' => AnalysisStatus.failed,
        _ => AnalysisStatus.pending,
      };

  static AssetType _parseAssetType(String raw) => switch (raw) {
        'service' => AssetType.service,
        'infrastructure' => AssetType.infrastructure,
        'network' => AssetType.network,
        'human' => AssetType.human,
        _ => AssetType.data,
      };

  static AssetSensitivity _parseAssetSensitivity(String raw) => switch (raw) {
        'low' => AssetSensitivity.low,
        'high' => AssetSensitivity.high,
        'critical' => AssetSensitivity.critical,
        _ => AssetSensitivity.medium,
      };

  static StrideCategory _parseStrideCategory(String raw) => switch (raw) {
        'spoofing' => StrideCategory.spoofing,
        'repudiation' => StrideCategory.repudiation,
        'information_disclosure' => StrideCategory.informationDisclosure,
        'denial_of_service' => StrideCategory.denialOfService,
        'elevation_of_privilege' => StrideCategory.elevationOfPrivilege,
        _ => StrideCategory.tampering,
      };

  static MitigationPriority _parseMitigationPriority(String raw) =>
      switch (raw) {
        'critical' => MitigationPriority.critical,
        'high' => MitigationPriority.high,
        'low' => MitigationPriority.low,
        _ => MitigationPriority.medium,
      };
}
