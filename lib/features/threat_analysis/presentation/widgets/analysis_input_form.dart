import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/threat_analysis.dart';
import '../providers/threat_analysis_providers.dart';

/// Full idle-state body for the Threat Analysis screen.
///
/// Contains:
///   1. System description input form with validation
///   2. "Recent Analyses" history list (from [analysisListProvider])
///
/// Passes [controller], [formKey], and [onAnalyze] from the parent
/// [ConsumerStatefulWidget] so it stays stateless here.
class AnalysisInputForm extends ConsumerWidget {
  const AnalysisInputForm({
    super.key,
    required this.controller,
    required this.formKey,
    required this.onAnalyze,
    required this.onViewResult,
  });

  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final VoidCallback onAnalyze;

  /// Called when the user taps on a history item to view its result.
  final ValueChanged<ThreatAnalysis> onViewResult;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeading(context),
              const SizedBox(height: 20),
              _buildInputCard(context),
              const SizedBox(height: 28),
              _AnalysisHistorySection(onViewResult: onViewResult),
            ],
          ),
        ),
      );

  Widget _buildHeading(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Threat Analysis',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Describe your system architecture to generate a comprehensive '
            'threat model using the STRIDE + DREAD methodology.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),
        ],
      );

  Widget _buildInputCard(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.edit_note,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'System Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller,
                maxLines: 8,
                minLines: 6,
                maxLength: 2000,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Describe your system…\n\n'
                      'Example: A web application with a REST API backend, '
                      'PostgreSQL database, and Redis cache. Users authenticate '
                      'via JWT tokens stored in HttpOnly cookies. The API is '
                      'publicly accessible and the admin panel is protected by '
                      'IP allow-list.',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe your system architecture.';
                  }
                  if (value.trim().length < 50) {
                    return 'Provide at least 50 characters for an accurate analysis.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onAnalyze,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  label: const Text('Analyze Threats'),
                  icon: const Icon(Icons.security),
                ),
              ),
            ],
          ),
        ),
      );
}

/// History section that watches [analysisListProvider] and renders past analyses.
class _AnalysisHistorySection extends ConsumerWidget {
  const _AnalysisHistorySection({required this.onViewResult});

  final ValueChanged<ThreatAnalysis> onViewResult;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(analysisListProvider);
    return listState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
      data: (analyses) {
        if (analyses.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Analyses',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...analyses.map(
              (a) => _AnalysisHistoryTile(
                analysis: a,
                onTap: () => onViewResult(a),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Single row in the history list.
class _AnalysisHistoryTile extends StatelessWidget {
  const _AnalysisHistoryTile({
    required this.analysis,
    required this.onTap,
  });

  final ThreatAnalysis analysis;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final score = analysis.riskScore;
    final riskColor = _riskColor(score);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: _ScorePill(score: score, color: riskColor),
        title: Text(
          analysis.systemDescription,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: Text(
          DateFormat('MMM d, yyyy • h:mm a').format(analysis.createdAt),
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_outlined, size: 14, color: Colors.grey),
            const SizedBox(width: 2),
            Text(
              '${analysis.threats.length}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  static Color _riskColor(double? score) {
    if (score == null) return Colors.grey;
    if (score <= 3) return Colors.green;
    if (score <= 6) return Colors.amber;
    if (score <= 8) return Colors.orange;
    return Colors.red;
  }
}

/// Compact pill showing the risk score.
class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.score, required this.color});

  final double? score;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withAlpha(30),
          border: Border.all(color: color.withAlpha(100)),
        ),
        child: Center(
          child: Text(
            score != null ? score!.toStringAsFixed(1) : '—',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      );
}
