import '../entities/chat_message.dart';

/// Repository interface for AI chat operations.
///
/// Domain layer rules:
/// - No Flutter imports
/// - No Dio imports
/// - No Supabase imports
abstract class ChatRepository {
  /// Send a message and get an AI response.
  ///
  /// The AI request flows through Supabase Edge Functions —
  /// the client never communicates directly with AI providers.
  Future<ChatMessage> sendMessage({
    required String analysisId,
    required String content,
  });

  /// Get chat history for an analysis.
  Future<List<ChatMessage>> getChatHistory(String analysisId);

  /// Stream of new messages for real-time updates.
  Stream<ChatMessage> watchMessages(String analysisId);
}
