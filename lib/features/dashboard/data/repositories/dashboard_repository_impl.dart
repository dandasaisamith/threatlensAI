import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/exceptions/app_exceptions.dart';
import '../../../threat_analysis/data/models/threat_analysis_model.dart';
import '../../../threat_analysis/domain/entities/threat_analysis.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// Data layer implementation of [DashboardRepository].
///
/// Communicates directly with Supabase to aggregate dashboard statistics.
class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  Future<DashboardStats> getDashboardStats(String userId) async {
    try {
      // 1. Query Supabase for all threat analyses and related data
      List<dynamic> data = [];
      try {
        data = await _supabaseClient
            .from('threat_analyses')
            .select('''
              *,
              assets (*),
              threats (
                *,
                dread_scores (*),
                mitigations (*)
              )
            ''')
            .eq('user_id', userId)
            .order('created_at', ascending: false);
      } catch (e) {
        // Fallback if mitigations table doesn't exist or is not accessible
        data = await _supabaseClient
            .from('threat_analyses')
            .select('''
              *,
              assets (*),
              threats (
                *,
                dread_scores (*)
              )
            ''')
            .eq('user_id', userId)
            .order('created_at', ascending: false);
      }

      final analyses = List<Map<String, dynamic>>.from(data)
          .map(ThreatAnalysisModel.fromJson)
          .toList();

      // 2. Aggregate statistics in Dart
      int totalAnalyses = analyses.length;
      int totalThreats = 0;
      int criticalThreats = 0;
      int highThreats = 0;
      int reportsGenerated = analyses.where((a) => a.status == AnalysisStatus.completed).length;

      for (final analysis in analyses) {
        for (final threat in analysis.threats) {
          totalThreats++;
          final dreadAverage = threat.dreadScore.average;
          if (dreadAverage >= 8.0) {
            criticalThreats++;
          } else if (dreadAverage >= 6.0) {
            highThreats++;
          }
        }
      }

      // 3. Extract recent analyses (top 5)
      final recentAnalyses = analyses.take(5).toList();

      return DashboardStats(
        totalAnalyses: totalAnalyses,
        totalThreats: totalThreats,
        criticalThreats: criticalThreats,
        highThreats: highThreats,
        reportsGenerated: reportsGenerated,
        recentAnalyses: recentAnalyses,
      );
    } catch (e) {
      throw _mapError(e);
    }
  }

  /// Ensure all thrown objects are typed [AppException] subclasses.
  AppException _mapError(Object error) {
    if (error is AppException) return error;
    return NetworkException(
      message: 'Failed to load dashboard statistics. Please try again.',
      originalError: error,
    );
  }
}
