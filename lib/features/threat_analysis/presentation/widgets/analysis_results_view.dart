import 'package:flutter/material.dart';

import '../../domain/entities/threat_analysis.dart';
import 'threat_card.dart';

/// Displays the completed results of a [ThreatAnalysis].
///
/// Sections:
///   1. Risk score summary card (color-coded)
///   2. Identified assets chips
///   3. Threats list (expandable [ThreatCard] widgets)
class AnalysisResultsView extends StatelessWidget {
  const AnalysisResultsView({super.key, required this.analysis});

  final ThreatAnalysis analysis;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RiskSummaryCard(analysis: analysis),
            if (analysis.assets.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionHeader(
                icon: Icons.inventory_2_outlined,
                title: 'Identified Assets (${analysis.assets.length})',
              ),
              const SizedBox(height: 8),
              _AssetsGrid(assets: analysis.assets),
            ],
            if (analysis.threats.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionHeader(
                icon: Icons.warning_amber_outlined,
                title: 'Threats (${analysis.threats.length})',
              ),
              const SizedBox(height: 8),
              ...analysis.threats.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ThreatCard(threat: t),
                ),
              ),
            ],
            if (analysis.threats.isEmpty && analysis.assets.isEmpty)
              _EmptyResultsPlaceholder(status: analysis.status),
            const SizedBox(height: 24),
          ],
        ),
      );
}

/// Summary card showing overall risk score and analysis metadata.
class _RiskSummaryCard extends StatelessWidget {
  const _RiskSummaryCard({required this.analysis});

  final ThreatAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final score = analysis.riskScore;
    final riskColor = _riskColor(score);
    final riskLabel = _riskLabel(score);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ScoreCircle(score: score, color: riskColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Risk Score',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        riskLabel,
                        style: TextStyle(
                          color: riskColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: analysis.status),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MetaStat(
                  icon: Icons.warning_outlined,
                  label: 'Threats',
                  value: '${analysis.threats.length}',
                ),
                _MetaStat(
                  icon: Icons.inventory_2_outlined,
                  label: 'Assets',
                  value: '${analysis.assets.length}',
                ),
                _MetaStat(
                  icon: Icons.shield_outlined,
                  label: 'Mitigations',
                  value: '${_totalMitigations(analysis)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static int _totalMitigations(ThreatAnalysis a) =>
      a.threats.fold(0, (sum, t) => sum + t.mitigations.length);

  static Color _riskColor(double? score) {
    if (score == null) return Colors.grey;
    if (score <= 3) return Colors.green;
    if (score <= 6) return Colors.amber;
    if (score <= 8) return Colors.orange;
    return Colors.red;
  }

  static String _riskLabel(double? score) {
    if (score == null) return 'Pending';
    if (score <= 3) return 'Low Risk';
    if (score <= 6) return 'Medium Risk';
    if (score <= 8) return 'High Risk';
    return 'Critical Risk';
  }
}

/// Circular score display.
class _ScoreCircle extends StatelessWidget {
  const _ScoreCircle({required this.score, required this.color});

  final double? score;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withAlpha(30),
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Text(
            score != null ? score!.toStringAsFixed(1) : '—',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      );
}

/// Status badge chip.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final AnalysisStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Chip(
      label: Text(
        status.name.toUpperCase(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color.withAlpha(30),
      side: BorderSide(color: color),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  static Color _statusColor(AnalysisStatus s) => switch (s) {
        AnalysisStatus.pending => Colors.grey,
        AnalysisStatus.analyzing => Colors.blue,
        AnalysisStatus.completed => Colors.green,
        AnalysisStatus.failed => Colors.red,
      };
}

/// A simple labelled stat column.
class _MetaStat extends StatelessWidget {
  const _MetaStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      );
}

/// Section header with an icon and bold title.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleSmall),
        ],
      );
}

/// Wrap of asset chips.
class _AssetsGrid extends StatelessWidget {
  const _AssetsGrid({required this.assets});

  final List<Asset> assets;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: assets.map((a) => _AssetChip(asset: a)).toList(),
      );
}

/// Single asset chip with sensitivity color.
class _AssetChip extends StatelessWidget {
  const _AssetChip({required this.asset});

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    final color = _sensitivityColor(asset.sensitivity);
    return Tooltip(
      message: asset.description,
      child: Chip(
        avatar: Icon(
          _assetIcon(asset.type),
          size: 14,
          color: color,
        ),
        label: Text(asset.name),
        side: BorderSide(color: color.withAlpha(80)),
        backgroundColor: color.withAlpha(20),
      ),
    );
  }

  static Color _sensitivityColor(AssetSensitivity s) => switch (s) {
        AssetSensitivity.low => Colors.green,
        AssetSensitivity.medium => Colors.amber,
        AssetSensitivity.high => Colors.orange,
        AssetSensitivity.critical => Colors.red,
      };

  static IconData _assetIcon(AssetType t) => switch (t) {
        AssetType.data => Icons.storage,
        AssetType.service => Icons.api,
        AssetType.infrastructure => Icons.dns,
        AssetType.network => Icons.lan,
        AssetType.human => Icons.person,
      };
}

/// Shown when analysis returned no assets or threats.
class _EmptyResultsPlaceholder extends StatelessWidget {
  const _EmptyResultsPlaceholder({required this.status});

  final AnalysisStatus status;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            children: [
              const Icon(Icons.shield_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                status == AnalysisStatus.analyzing
                    ? 'Analysis in progress…'
                    : 'No threats detected',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                status == AnalysisStatus.analyzing
                    ? 'Results will appear when the AI finishes.'
                    : 'Your system description did not surface any threats.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
}
