import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

/// Use case for sending a chat message.
class SendMessageUseCase {
  SendMessageUseCase({required ChatRepository repository})
      : _repository = repository;

  final ChatRepository _repository;

  Future<ChatMessage> call({
    required String analysisId,
    required String content,
  }) {
    return _repository.sendMessage(
      analysisId: analysisId,
      content: content,
    );
  }
}

/// Use case for getting chat history.
class GetChatHistoryUseCase {
  GetChatHistoryUseCase({required ChatRepository repository})
      : _repository = repository;

  final ChatRepository _repository;

  Future<List<ChatMessage>> call(String analysisId) =>
      _repository.getChatHistory(analysisId);
}
