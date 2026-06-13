import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

import '../../../../core/security/secure_storage_service.dart';
import '../../../threat_analysis/presentation/providers/threat_analysis_providers.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';

// =============================================================================
// Infrastructure providers
// =============================================================================

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => ReportRepositoryImpl(
    supabaseClient: Supabase.instance.client,
    threatAnalysisRepository: ref.watch(threatAnalysisRepositoryProvider),
  ),
);

// =============================================================================
// State: Generate Report
// =============================================================================

sealed class GenerateReportState {
  const GenerateReportState();
}

class GenerateReportIdle extends GenerateReportState {
  const GenerateReportIdle();
}

class GenerateReportLoading extends GenerateReportState {
  const GenerateReportLoading();
}

class GenerateReportSuccess extends GenerateReportState {
  const GenerateReportSuccess(this.report);
  final Report report;
}

class GenerateReportError extends GenerateReportState {
  const GenerateReportError(this.message);
  final String message;
}

final generateReportProvider = NotifierProvider.autoDispose<GenerateReportNotifier, GenerateReportState>(
  GenerateReportNotifier.new,
);

class GenerateReportNotifier extends AutoDisposeNotifier<GenerateReportState> {
  @override
  GenerateReportState build() => const GenerateReportIdle();

  Future<void> generateReport(String analysisId) async {
    state = const GenerateReportLoading();
    try {
      final storage = GetIt.instance<SecureStorageService>();
      final userId = await storage.getUserId();

      if (userId == null || userId.isEmpty) {
        state = const GenerateReportError('User not authenticated.');
        return;
      }

      final repo = ref.read(reportRepositoryProvider);
      final report = await repo.generateReport(
        analysisId: analysisId,
        userId: userId,
        format: ReportFormat.pdf,
      );

      ref.read(reportListProvider.notifier).addReport(report);
      state = GenerateReportSuccess(report);
    } catch (e) {
      state = GenerateReportError(e.toString());
    }
  }

  void reset() => state = const GenerateReportIdle();
}

// =============================================================================
// State: Report List
// =============================================================================

final reportListProvider = AsyncNotifierProvider<ReportListNotifier, List<Report>>(
  ReportListNotifier.new,
);

class ReportListNotifier extends AsyncNotifier<List<Report>> {
  @override
  Future<List<Report>> build() => _fetch();

  Future<List<Report>> _fetch() async {
    final storage = GetIt.instance<SecureStorageService>();
    final userId = await storage.getUserId();
    if (userId == null || userId.isEmpty) return const [];

    final repo = ref.read(reportRepositoryProvider);
    return repo.getReportsByUser(userId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  void addReport(Report report) {
    final current = state.valueOrNull ?? const [];
    state = AsyncData([report, ...current]);
  }

  Future<void> deleteReport(String reportId) async {
    try {
      final repo = ref.read(reportRepositoryProvider);
      await repo.deleteReport(reportId);
      final current = state.valueOrNull ?? const [];
      state = AsyncData(current.where((r) => r.id != reportId).toList());
    } catch (e) {
      // Could throw error or handle silently. For now let it propagate
      rethrow;
    }
  }

  Future<void> exportReport(String reportId) async {
    final repo = ref.read(reportRepositoryProvider);
    await repo.exportReport(reportId);
  }
}
