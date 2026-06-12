import '../../../../core/network/api_client.dart';
import '../../../../config/environment_config.dart';

/// Remote data source for threat analysis operations.
///
/// Communicates only with Supabase Edge Functions — never with AI providers directly.
/// All AI provider credentials are managed server-side.
class ThreatAnalysisRemoteDataSource {
  ThreatAnalysisRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  String get _baseUrl => EnvironmentConfig.edgeFunctionBaseUrl;

  /// Create a new threat analysis via Edge Function.
  Future<Map<String, dynamic>> createAnalysis({
    required String userId,
    required String systemDescription,
  }) async {
    final response = await _apiClient.post(
      '$_baseUrl/threat-analysis',
      data: {'userId': userId, 'systemDescription': systemDescription},
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get an analysis by ID.
  Future<Map<String, dynamic>?> getAnalysisById(String id) async {
    try {
      final response = await _apiClient.get('$_baseUrl/threat-analysis/$id');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  /// Get all analyses for a user.
  Future<List<Map<String, dynamic>>> getAnalysesByUser(String userId) async {
    final response = await _apiClient.get(
      '$_baseUrl/threat-analysis',
      queryParameters: {'userId': userId},
    );
    return (response.data as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  /// Delete an analysis.
  Future<void> deleteAnalysis(String id) async {
    await _apiClient.delete('$_baseUrl/threat-analysis/$id');
  }
}
