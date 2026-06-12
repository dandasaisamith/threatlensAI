import '../../../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/threat_analysis.dart';
import '../../domain/repositories/threat_analysis_repository.dart';
import '../datasources/threat_analysis_local_datasource.dart';
import '../datasources/threat_analysis_remote_datasource.dart';
import '../models/threat_analysis_model.dart';

/// Data layer implementation of [ThreatAnalysisRepository].
///
/// Coordinates [ThreatAnalysisRemoteDataSource] (Supabase Edge Functions)
/// and [ThreatAnalysisLocalDataSource] (Isar offline cache).
///
/// Offline strategy: on network failure the repository attempts to serve
/// locally cached data before re-throwing a typed [AppException].
///
/// Error mapping: any exception that is not already an [AppException] is
/// wrapped in a [NetworkException] so callers only ever see typed errors.
class ThreatAnalysisRepositoryImpl implements ThreatAnalysisRepository {
  ThreatAnalysisRepositoryImpl({
    required ThreatAnalysisRemoteDataSource remoteDataSource,
    required ThreatAnalysisLocalDataSource localDataSource,
  })  : _remote = remoteDataSource,
        _local = localDataSource;

  final ThreatAnalysisRemoteDataSource _remote;
  final ThreatAnalysisLocalDataSource _local;

  // ---------------------------------------------------------------------------
  // Write operations
  // ---------------------------------------------------------------------------

  @override
  Future<ThreatAnalysis> createAnalysis({
    required String userId,
    required String systemDescription,
  }) async {
    try {
      final json = await _remote.createAnalysis(
        userId: userId,
        systemDescription: systemDescription,
      );
      final analysis = ThreatAnalysisModel.fromJson(json);
      // Cache the successful result for offline access.
      await _local.cacheAnalysis(id: analysis.id, data: json);
      return analysis;
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<ThreatAnalysis> updateAnalysis(ThreatAnalysis analysis) =>
      throw UnimplementedError(
        'updateAnalysis is not yet implemented. '
        'It will be added in the analysis editing phase.',
      );

  @override
  Future<void> deleteAnalysis(String id) async {
    try {
      await _remote.deleteAnalysis(id);
      await _local.deleteCachedAnalysis(id);
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Read operations
  // ---------------------------------------------------------------------------

  @override
  Future<ThreatAnalysis?> getAnalysisById(String id) async {
    try {
      final json = await _remote.getAnalysisById(id);
      if (json == null) return null;
      return ThreatAnalysisModel.fromJson(json);
    } catch (e) {
      // Fall back to local cache on network failure.
      final cached = await _local.getCachedAnalysis(id);
      if (cached != null) return ThreatAnalysisModel.fromJson(cached);
      throw _mapError(e);
    }
  }

  @override
  Future<List<ThreatAnalysis>> getAnalysesByUser(String userId) async {
    try {
      final jsonList = await _remote.getAnalysesByUser(userId);
      return jsonList.map(ThreatAnalysisModel.fromJson).toList();
    } catch (e) {
      // Fall back to local cache on network failure.
      final cached = await _local.getCachedAnalyses(userId);
      if (cached.isNotEmpty) {
        return cached.map(ThreatAnalysisModel.fromJson).toList();
      }
      throw _mapError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Real-time stream
  // ---------------------------------------------------------------------------

  /// Polls the remote source every 5 seconds until a result is returned.
  ///
  /// Supabase Realtime subscription is planned for Phase 3.
  @override
  Stream<ThreatAnalysis> watchAnalysis(String id) =>
      Stream.periodic(const Duration(seconds: 5))
          .asyncMap((_) => getAnalysisById(id))
          .where((a) => a != null)
          .cast<ThreatAnalysis>();

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Ensure all thrown objects are typed [AppException] subclasses.
  AppException _mapError(Object error) {
    if (error is AppException) return error;
    return NetworkException(
      message: 'Threat analysis request failed. Please try again.',
      originalError: error,
    );
  }
}
