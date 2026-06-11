/// Domain entity representing a threat analysis.
///
/// Pure domain model — no framework dependencies.
/// Follows STRIDE methodology for threat classification.
class ThreatAnalysis {
  const ThreatAnalysis({
    required this.id,
    required this.userId,
    required this.systemDescription,
    required this.assets,
    required this.threats,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.riskScore,
  });

  final String id;
  final String userId;
  final String systemDescription;
  final List<Asset> assets;
  final List<Threat> threats;
  final AnalysisStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final double? riskScore;
}

/// Represents an asset identified in the system architecture.
class Asset {
  const Asset({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.sensitivity,
  });

  final String id;
  final String name;
  final AssetType type;
  final String description;
  final AssetSensitivity sensitivity;
}

/// Types of assets that can be identified.
enum AssetType {
  data,
  service,
  infrastructure,
  network,
  human,
}

/// Sensitivity levels for assets.
enum AssetSensitivity {
  low,
  medium,
  high,
  critical,
}

/// Represents a threat identified through STRIDE analysis.
class Threat {
  const Threat({
    required this.id,
    required this.name,
    required this.description,
    required this.strideCategory,
    required this.affectedAssets,
    required this.dreadScore,
    this.mitigations = const [],
  });

  final String id;
  final String name;
  final String description;
  final StrideCategory strideCategory;
  final List<String> affectedAssets;
  final DreadScore dreadScore;
  final List<Mitigation> mitigations;
}

/// STRIDE threat classification categories.
enum StrideCategory {
  spoofing,
  tampering,
  repudiation,
  informationDisclosure,
  denialOfService,
  elevationOfPrivilege,
}

/// DREAD risk scoring model.
class DreadScore {
  const DreadScore({
    required this.damagePotential,
    required this.reproducibility,
    required this.exploitability,
    required this.affectedUsers,
    required this.discoverability,
  });

  final int damagePotential;
  final int reproducibility;
  final int exploitability;
  final int affectedUsers;
  final int discoverability;

  /// Average DREAD score (1-10 scale).
  double get average =>
      (damagePotential + reproducibility + exploitability +
          affectedUsers + discoverability) /
      5.0;
}

/// A mitigation strategy for a threat.
class Mitigation {
  const Mitigation({
    required this.id,
    required this.description,
    required this.priority,
    required this.implementation,
  });

  final String id;
  final String description;
  final MitigationPriority priority;
  final String implementation;
}

/// Priority levels for mitigations.
enum MitigationPriority {
  critical,
  high,
  medium,
  low,
}

/// Status of a threat analysis.
enum AnalysisStatus {
  pending,
  analyzing,
  completed,
  failed,
}
