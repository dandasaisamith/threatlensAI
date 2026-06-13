import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/loading_widget.dart';
import '../../../threat_analysis/domain/entities/threat_analysis.dart';
import '../providers/dashboard_providers.dart';
import '../../domain/entities/dashboard_stats.dart';

/// Main dashboard screen.
/// Displays statistics and recent analyses.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ThreatLens AI Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(dashboardStatsProvider.notifier).refresh(),
            tooltip: 'Refresh Dashboard',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardStatsProvider.notifier).refresh(),
        child: state.when(
          data: (stats) => _buildContent(context, stats),
          loading: () => const Center(child: LoadingWidget(message: 'Loading Dashboard...')),
          error: (error, stack) => _buildError(context, ref, error),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load dashboard',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(dashboardStatsProvider.notifier).refresh(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DashboardStats stats) {
    if (stats.totalAnalyses == 0) {
      return _buildEmptyState(context);
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildStatsGrid(context, stats),
        const SizedBox(height: 32),
        Text(
          'Recent Analyses',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...stats.recentAnalyses.map((analysis) => _buildAnalysisCard(context, analysis)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'No analyses found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new threat analysis to see your dashboard.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, DashboardStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _StatCard(
              title: 'Total Analyses',
              value: stats.totalAnalyses.toString(),
              icon: Icons.folder_special,
              color: Theme.of(context).colorScheme.primary,
            ),
            _StatCard(
              title: 'Total Threats',
              value: stats.totalThreats.toString(),
              icon: Icons.warning_amber_rounded,
              color: Colors.orange,
            ),
            _StatCard(
              title: 'Critical Threats',
              value: stats.criticalThreats.toString(),
              icon: Icons.gpp_bad,
              color: Theme.of(context).colorScheme.error,
            ),
            _StatCard(
              title: 'Reports Generated',
              value: stats.reportsGenerated.toString(),
              icon: Icons.summarize,
              color: Colors.green,
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalysisCard(BuildContext context, ThreatAnalysis analysis) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          'Analysis: ${analysis.id.substring(0, 8)}...',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Status: ${analysis.status.name.toUpperCase()} • ${analysis.threats.length} threats'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to analysis details using go_router
          context.push('/analysis/${analysis.id}');
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
