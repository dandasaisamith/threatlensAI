/// Domain entity for a chat message in the AI chat feature.
///
/// Pure domain model — no framework dependencies.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.analysisId,
    required this.content,
    required this.role,
    required this.timestamp,
  });

  final String id;
  final String analysisId;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
}

/// Role of a message participant.
enum MessageRole {
  user,
  assistant,
  system,
}
