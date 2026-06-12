import 'package:flutter/material.dart';

import '../../domain/entities/threat_analysis.dart';

/// Expandable card that displays a single [Threat].
///
/// Shows: STRIDE category label, DREAD risk score, description,
/// affected assets, and mitigation strategies.
class ThreatCard extends StatelessWidget {
  const ThreatCard({super.key, required this.threat});

  final Threat threat;

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          leading: _StrideBadge(category: threat.strideCategory),
          title: Text(
            threat.name,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Row(
            children: [
              Text(
                _strideName(threat.strideCategory),
                style: TextStyle(
                  color: _strideColor(threat.strideCategory),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '• DREAD ${threat.dreadScore.average.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          children: [
            _ThreatDetail(threat: threat),
          ],
        ),
      );

  static String _strideName(StrideCategory c) => switch (c) {
        StrideCategory.spoofing => 'Spoofing',
        StrideCategory.tampering => 'Tampering',
        StrideCategory.repudiation => 'Repudiation',
        StrideCategory.informationDisclosure => 'Info Disclosure',
        StrideCategory.denialOfService => 'Denial of Service',
        StrideCategory.elevationOfPrivilege => 'Privilege Escalation',
      };

  static Color _strideColor(StrideCategory c) => switch (c) {
        StrideCategory.spoofing => const Color(0xFF60A5FA),       // blue-400
        StrideCategory.tampering => const Color(0xFFF97316),      // orange-500
        StrideCategory.repudiation => const Color(0xFFA78BFA),    // violet-400
        StrideCategory.informationDisclosure => const Color(0xFFFBBF24), // amber-400
        StrideCategory.denialOfService => const Color(0xFFF87171), // red-400
        StrideCategory.elevationOfPrivilege => const Color(0xFF34D399), // emerald-400
      };
}

/// Circular badge showing the first letter of the STRIDE category.
class _StrideBadge extends StatelessWidget {
  const _StrideBadge({required this.category});

  final StrideCategory category;

  @override
  Widget build(BuildContext context) {
    final color = ThreatCard._strideColor(category);
    return CircleAvatar(
      radius: 18,
      backgroundColor: color.withAlpha(40),
      child: Text(
        _initial(category),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  static String _initial(StrideCategory c) => switch (c) {
        StrideCategory.spoofing => 'S',
        StrideCategory.tampering => 'T',
        StrideCategory.repudiation => 'R',
        StrideCategory.informationDisclosure => 'I',
        StrideCategory.denialOfService => 'D',
        StrideCategory.elevationOfPrivilege => 'E',
      };
}

/// Expanded detail panel for a single threat.
class _ThreatDetail extends StatelessWidget {
  const _ThreatDetail({required this.threat});

  final Threat threat;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            // Description
            if (threat.description.isNotEmpty) ...[
              Text(
                threat.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
            ],
            // DREAD breakdown
            _DreadScoreRow(score: threat.dreadScore),
            // Affected assets
            if (threat.affectedAssets.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Affected Assets',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: threat.affectedAssets
                    .map(
                      (id) => Chip(
                        label: Text(id, style: const TextStyle(fontSize: 11)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
            ],
            // Mitigations
            if (threat.mitigations.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Mitigations',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 6),
              ...threat.mitigations.map(
                (m) => _MitigationRow(mitigation: m),
              ),
            ],
          ],
        ),
      );
}

/// Horizontal display of all five DREAD score dimensions.
class _DreadScoreRow extends StatelessWidget {
  const _DreadScoreRow({required this.score});

  final DreadScore score;

  @override
  Widget build(BuildContext context) {
    final avg = score.average;
    final color = _scoreColor(avg);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DREAD Score',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: Colors.grey),
              ),
              Text(
                avg.toStringAsFixed(1),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _DreadDimension(label: 'Damage', value: score.damagePotential),
              _DreadDimension(label: 'Repro', value: score.reproducibility),
              _DreadDimension(label: 'Exploit', value: score.exploitability),
              _DreadDimension(label: 'Users', value: score.affectedUsers),
              _DreadDimension(label: 'Discover', value: score.discoverability),
            ],
          ),
        ],
      ),
    );
  }

  static Color _scoreColor(double avg) {
    if (avg <= 3) return Colors.green;
    if (avg <= 6) return Colors.amber;
    if (avg <= 8) return Colors.orange;
    return Colors.red;
  }
}

/// A single DREAD dimension label + value pill.
class _DreadDimension extends StatelessWidget {
  const _DreadDimension({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(
            '$value',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      );
}

/// Single mitigation row with priority indicator.
class _MitigationRow extends StatelessWidget {
  const _MitigationRow({required this.mitigation});

  final Mitigation mitigation;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 5, right: 8),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _priorityColor(mitigation.priority),
              ),
            ),
            Expanded(
              child: Text(
                mitigation.description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );

  static Color _priorityColor(MitigationPriority p) => switch (p) {
        MitigationPriority.critical => Colors.red,
        MitigationPriority.high => Colors.orange,
        MitigationPriority.medium => Colors.amber,
        MitigationPriority.low => Colors.green,
      };
}
