import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/report.dart';
import '../providers/report_providers.dart';

/// Reports screen
/// 
/// Allows users to:
/// - View generated reports
/// - Share reports
/// - Delete reports
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportListState = ref.watch(reportListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(reportListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: reportListState.when(
        loading: () => const LoadingWidget(message: 'Loading reports...'),
        error: (error, _) => _buildError(context, ref, error),
        data: (reports) => _buildData(context, ref, reports),
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
              'Failed to load reports',
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
            FilledButton.icon(
              onPressed: () => ref.read(reportListProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildData(BuildContext context, WidgetRef ref, List<Report> reports) {
    if (reports.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(reportListProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return _ReportCard(report: report);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'No reports generated',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Generate a report from an analysis to see it here.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends ConsumerWidget {
  const _ReportCard({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.picture_as_pdf, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          report.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Generated: ${report.generatedAt.toIso8601String().split('T').first}'),
            if (report.fileSizeBytes != null)
              Text('Size: ${(report.fileSizeBytes! / 1024).toStringAsFixed(1)} KB'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                ref.read(reportListProvider.notifier).exportReport(report.id);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              onPressed: () {
                _confirmDelete(context, ref, report);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(reportListProvider.notifier).deleteReport(report.id);
              Navigator.of(context).pop();
            },
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
