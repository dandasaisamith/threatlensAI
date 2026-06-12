import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/threat_analysis.dart';
import '../providers/threat_analysis_providers.dart';
import '../widgets/analysis_input_form.dart';
import '../widgets/analysis_results_view.dart';

/// Threat Analysis feature entry screen.
///
/// Manages a single [TextEditingController] and [FormKey] and delegates the
/// body to child widgets based on the current [CreateAnalysisState]:
///
/// ```
/// CreateAnalysisIdle    → AnalysisInputForm + history list
/// CreateAnalysisLoading → centered spinner
/// CreateAnalysisSuccess → AnalysisResultsView
/// CreateAnalysisError   → error panel with retry button
/// ```
class ThreatAnalysisScreen extends ConsumerStatefulWidget {
  const ThreatAnalysisScreen({super.key});

  @override
  ConsumerState<ThreatAnalysisScreen> createState() =>
      _ThreatAnalysisScreenState();
}

class _ThreatAnalysisScreenState
    extends ConsumerState<ThreatAnalysisScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(createAnalysisProvider.notifier)
        .createAnalysis(_controller.text.trim());
  }

  void _reset() {
    ref.read(createAnalysisProvider.notifier).reset();
    _controller.clear();
  }

  /// Show a past analysis result without re-running the analysis.
  void _viewHistoricResult(ThreatAnalysis analysis) {
    // Navigate to a dedicated result view for historic items.
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _HistoricResultScreen(analysis: analysis),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createAnalysisProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Threat Analysis'),
        actions: [
          if (createState is! CreateAnalysisIdle)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'New Analysis',
              onPressed: _reset,
            ),
        ],
      ),
      body: switch (createState) {
        CreateAnalysisIdle() => AnalysisInputForm(
            controller: _controller,
            formKey: _formKey,
            onAnalyze: _submit,
            onViewResult: _viewHistoricResult,
          ),
        CreateAnalysisLoading() => _buildLoadingView(),
        CreateAnalysisSuccess(:final analysis) =>
          AnalysisResultsView(analysis: analysis),
        CreateAnalysisError(:final message) => _buildErrorView(message),
      },
    );
  }

  // ---------------------------------------------------------------------------
  // State-specific views
  // ---------------------------------------------------------------------------

  Widget _buildLoadingView() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text(
              'Analyzing your system…',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'The AI is running STRIDE classification and DREAD scoring.\n'
              'This may take a moment.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );

  Widget _buildErrorView(String message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 72,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 20),
              Text(
                'Analysis Failed',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
}

/// Read-only result screen for items selected from the history list.
class _HistoricResultScreen extends StatelessWidget {
  const _HistoricResultScreen({required this.analysis});

  final ThreatAnalysis analysis;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Analysis Result',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        body: AnalysisResultsView(analysis: analysis),
      );
}
