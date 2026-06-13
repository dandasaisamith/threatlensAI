import '../../../threat_analysis/domain/entities/threat_analysis.dart';

/// Domain entity holding aggregated statistics for the dashboard.
class DashboardStats {
  const DashboardStats({
    required this.totalAnalyses,
    required this.totalThreats,
    required this.criticalThreats,
    required this.highThreats,
    required this.reportsGenerated,
    required this.recentAnalyses,
  });

  final int totalAnalyses;
  final int totalThreats;
  final int criticalThreats;
  final int highThreats;
  final int reportsGenerated;
  final List<ThreatAnalysis> recentAnalyses;

  /// Returns an empty/zero state for the dashboard.
  factory DashboardStats.empty() => const DashboardStats(
        totalAnalyses: 0,
        totalThreats: 0,
        criticalThreats: 0,
        highThreats: 0,
        reportsGenerated: 0,
        recentAnalyses: [],
      );
}
