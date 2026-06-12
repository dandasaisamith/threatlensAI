import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/security/secure_storage_service.dart';
import '../../../../core/services/initialization_service.dart';
import '../../data/datasources/threat_analysis_local_datasource.dart';
import '../../data/datasources/threat_analysis_remote_datasource.dart';
import '../../data/repositories/threat_analysis_repository_impl.dart';
import '../../domain/entities/threat_analysis.dart';
import '../../domain/repositories/threat_analysis_repository.dart';
import '../../domain/use_cases/threat_analysis_use_cases.dart';

// =============================================================================
// Infrastructure providers — singleton lifetime (not auto-disposed)
// =============================================================================

/// Provides the fully-wired [ThreatAnalysisRepository].
///
/// Uses [GetIt] to access [ApiClient] (registered at startup) and
/// [InitializationService.isar] for the local Isar instance.
final threatAnalysisRepositoryProvider = Provider<ThreatAnalysisRepository>(
  (ref) => ThreatAnalysisRepositoryImpl(
    remoteDataSource: ThreatAnalysisRemoteDataSource(
      apiClient: GetIt.instance<ApiClient>(),
    ),
    localDataSource: ThreatAnalysisLocalDataSource(
      isar: InitializationService.isar,
    ),
  ),
);

/// Use case: create a new analysis.
final createAnalysisUseCaseProvider = Provider<CreateAnalysisUseCase>(
  (ref) => CreateAnalysisUseCase(
    repository: ref.watch(threatAnalysisRepositoryProvider),
  ),
);

/// Use case: fetch all analyses for the current user.
final getAnalysesByUserUseCaseProvider = Provider<GetAnalysesByUserUseCase>(
  (ref) => GetAnalysesByUserUseCase(
    repository: ref.watch(threatAnalysisRepositoryProvider),
  ),
);

/// Use case: delete an analysis.
final deleteAnalysisUseCaseProvider = Provider<DeleteAnalysisUseCase>(
  (ref) => DeleteAnalysisUseCase(
    repository: ref.watch(threatAnalysisRepositoryProvider),
  ),
);

// =============================================================================
// State: Create Analysis — auto-disposed so screen returns to idle on pop
// =============================================================================

/// The state emitted by [createAnalysisProvider].
sealed class CreateAnalysisState {
  const CreateAnalysisState();
}

/// Initial idle state — the input form is shown.
class CreateAnalysisIdle extends CreateAnalysisState {
  const CreateAnalysisIdle();
}

/// Analysis is in progress — show spinner.
class CreateAnalysisLoading extends CreateAnalysisState {
  const CreateAnalysisLoading();
}

/// Analysis succeeded — carry the result entity.
class CreateAnalysisSuccess extends CreateAnalysisState {
  const CreateAnalysisSuccess(this.analysis);
  final ThreatAnalysis analysis;
}

/// Analysis failed — carry a user-facing error message.
class CreateAnalysisError extends CreateAnalysisState {
  const CreateAnalysisError(this.message);
  final String message;
}

/// Manages the lifecycle of a single "create analysis" flow.
///
/// Auto-disposed when the screen leaves the navigation stack, which
/// resets state so re-entering always shows a fresh input form.
final createAnalysisProvider = NotifierProvider.autoDispose<
    CreateAnalysisNotifier, CreateAnalysisState>(CreateAnalysisNotifier.new);

/// Notifier for the create-analysis flow.
class CreateAnalysisNotifier extends AutoDisposeNotifier<CreateAnalysisState> {
  @override
  CreateAnalysisState build() => const CreateAnalysisIdle();

  /// Runs the threat analysis pipeline for [systemDescription].
  Future<void> createAnalysis(String systemDescription) async {
    state = const CreateAnalysisLoading();

    try {
      final storage = GetIt.instance<SecureStorageService>();
      final userId = await storage.getUserId();

      if (userId == null || userId.isEmpty) {
        state = const CreateAnalysisError(
          'You are not signed in. Please log in and try again.',
        );
        return;
      }

      final useCase = ref.read(createAnalysisUseCaseProvider);
      final analysis = await useCase.call(
        userId: userId,
        systemDescription: systemDescription,
      );

      // Prepend the new analysis to the persistent list cache.
      ref.read(analysisListProvider.notifier).addAnalysis(analysis);

      state = CreateAnalysisSuccess(analysis);
    } catch (e) {
      state = CreateAnalysisError(_friendlyMessage(e));
    }
  }

  /// Return to idle (used by the "New Analysis" / "Try Again" buttons).
  void reset() => state = const CreateAnalysisIdle();

  /// Convert raw exceptions to concise, user-facing messages.
  String _friendlyMessage(Object e) {
    final raw = e.toString().toLowerCase();
    if (raw.contains('socketexception') || raw.contains('connection')) {
      return 'No network connection. Check your internet and try again.';
    }
    if (raw.contains('401') || raw.contains('403')) {
      return 'Session expired. Please sign in again.';
    }
    if (raw.contains('timeout')) {
      return 'Request timed out. The AI analysis may take a moment — try again.';
    }
    return 'Analysis failed. Please try again.';
  }
}

// =============================================================================
// State: Analysis List — persistent, shared across the app
// =============================================================================

/// Provides the cached list of the current user's threat analyses.
///
/// Non-autoDispose so the list survives navigation and is not re-fetched
/// each time the screen is visited.
final analysisListProvider =
    AsyncNotifierProvider<AnalysisListNotifier, List<ThreatAnalysis>>(
  AnalysisListNotifier.new,
);

/// Notifier for the user's analysis history.
class AnalysisListNotifier extends AsyncNotifier<List<ThreatAnalysis>> {
  @override
  Future<List<ThreatAnalysis>> build() => _fetch();

  Future<List<ThreatAnalysis>> _fetch() async {
    final storage = GetIt.instance<SecureStorageService>();
    final userId = await storage.getUserId();
    if (userId == null || userId.isEmpty) return const [];

    final useCase = ref.read(getAnalysesByUserUseCaseProvider);
    return useCase.call(userId);
  }

  /// Force a fresh fetch from remote (e.g., pull-to-refresh).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  /// Prepend a newly-created analysis to the in-memory list without re-fetching.
  void addAnalysis(ThreatAnalysis analysis) {
    final current = state.valueOrNull ?? const [];
    state = AsyncData([analysis, ...current]);
  }

  /// Remove an analysis from the in-memory list after deletion.
  void removeAnalysis(String id) {
    final current = state.valueOrNull ?? const [];
    state = AsyncData(current.where((a) => a.id != id).toList());
  }
}
