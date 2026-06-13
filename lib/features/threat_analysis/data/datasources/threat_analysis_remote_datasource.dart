import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for threat analysis operations.
///
/// Communicates with Supabase Edge Functions for analysis generation
/// and Supabase Database for CRUD operations.
class ThreatAnalysisRemoteDataSource {
  ThreatAnalysisRemoteDataSource({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  /// Create a new threat analysis via Edge Function.
  Future<Map<String, dynamic>> createAnalysis({
    required String userId,
    required String systemDescription,
  }) async {
    // Invoke the edge function
    final response = await _supabaseClient.functions.invoke(
      'threat-analysis',
      body: {
        'userId': userId,
        'architectureDescription': systemDescription,
      },
    );
    
    final payload = response.data as Map<String, dynamic>;

    // Extract overall risk
    final riskScoreStr = payload['overallRisk']?.toString();
    double? riskScore;
    if (riskScoreStr != null) {
      final match = RegExp(r'[0-9.]+').firstMatch(riskScoreStr);
      if (match != null) {
        riskScore = double.tryParse(match.group(0)!);
      }
    }

    // 1. Insert analysis
    final analysisData = await _supabaseClient.from('threat_analyses').insert({
      'user_id': userId,
      'system_description': systemDescription,
      'status': 'completed',
      'risk_score': riskScore,
    }).select().single();

    final analysisId = analysisData['id'] as String;

    // 2. Insert assets
    final assetsRaw = payload['assets'] as List<dynamic>? ?? [];
    if (assetsRaw.isNotEmpty) {
      final assetsToInsert = assetsRaw.map((a) {
        final assetMap = a as Map<String, dynamic>;
        return {
          'id': assetMap['id'],
          'analysis_id': analysisId,
          'name': assetMap['name'] ?? assetMap['title'] ?? 'Unknown Asset',
          'description': assetMap['description'] ?? '',
          'type': assetMap['type'] ?? 'data',
          'sensitivity': assetMap['sensitivity'] ?? 'medium',
        };
      }).toList();
      await _supabaseClient.from('assets').insert(assetsToInsert);
    }

    // 3. Insert threats
    final threatsRaw = payload['threats'] as List<dynamic>? ?? [];
    if (threatsRaw.isNotEmpty) {
      final threatsToInsert = threatsRaw.map((t) {
        final threatMap = t as Map<String, dynamic>;
        return {
          'id': threatMap['id'],
          'analysis_id': analysisId,
          'name': threatMap['title'] ?? threatMap['name'] ?? 'Unknown Threat',
          'description': threatMap['description'] ?? '',
          'stride_category': threatMap['strideCategory'] ?? 'tampering',
        };
      }).toList();
      await _supabaseClient.from('threats').insert(threatsToInsert);
    }

    // 4. Insert dread scores
    final dreadScoresRaw = payload['dreadScores'] as List<dynamic>? ?? [];
    if (dreadScoresRaw.isNotEmpty) {
      final dreadsToInsert = dreadScoresRaw.map((d) {
        final dMap = d as Map<String, dynamic>;
        return {
          'threat_id': dMap['threatId'],
          'damage': dMap['damage'] ?? 5,
          'reproducibility': dMap['reproducibility'] ?? 5,
          'exploitability': dMap['exploitability'] ?? 5,
          'affected_users': dMap['affectedUsers'] ?? 5,
          'discoverability': dMap['discoverability'] ?? 5,
        };
      }).toList();
      await _supabaseClient.from('dread_scores').insert(dreadsToInsert);
    }

    // 5. Insert mitigations (if table exists)
    final mitigationsRaw = payload['mitigations'] as List<dynamic>? ?? [];
    if (mitigationsRaw.isNotEmpty) {
      try {
        final mitigationsToInsert = mitigationsRaw.map((m) {
          final mMap = m as Map<String, dynamic>;
          return {
            'id': mMap['id'],
            'threat_id': mMap['threatId'],
            'description': mMap['description'] ?? '',
            'priority': mMap['priority'] ?? 'medium',
            'implementation': mMap['status'] ?? '',
          };
        }).toList();
        await _supabaseClient.from('mitigations').insert(mitigationsToInsert);
      } catch (e) {
        // Ignore if mitigations table doesn't exist
      }
    }

    // Fetch the complete constructed object
    final finalData = await getAnalysisById(analysisId);
    return finalData ?? analysisData;
  }

  /// Get an analysis by ID from the database.
  Future<Map<String, dynamic>?> getAnalysisById(String id) async {
    try {
      final data = await _supabaseClient
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
          .eq('id', id)
          .maybeSingle();
      return data;
    } catch (e) {
      // Fallback if mitigations table doesn't exist
      try {
        final data = await _supabaseClient
            .from('threat_analyses')
            .select('''
              *,
              assets (*),
              threats (
                *,
                dread_scores (*)
              )
            ''')
            .eq('id', id)
            .maybeSingle();
        return data;
      } catch (e2) {
        return null;
      }
    }
  }

  /// Get all analyses for a user from the database.
  Future<List<Map<String, dynamic>>> getAnalysesByUser(String userId) async {
    try {
      final data = await _supabaseClient
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
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
       final data = await _supabaseClient
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
      return List<Map<String, dynamic>>.from(data);
    }
  }

  /// Delete an analysis from the database.
  Future<void> deleteAnalysis(String id) async {
    await _supabaseClient.from('threat_analyses').delete().eq('id', id);
  }
}
