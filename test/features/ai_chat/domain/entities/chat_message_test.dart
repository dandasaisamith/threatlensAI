import 'package:flutter_test/flutter_test.dart';
import 'package:threatlensia/features/ai_chat/domain/entities/chat_message.dart';

void main() {
  group('ChatMessage entity', () {
    test('creates with required fields', () {
      final message = ChatMessage(
        id: 'msg-1',
        analysisId: 'analysis-1',
        content: 'What are the main threats?',
        role: MessageRole.user,
        timestamp: DateTime(2024, 6, 10, 12, 0),
      );

      expect(message.id, 'msg-1');
      expect(message.analysisId, 'analysis-1');
      expect(message.content, 'What are the main threats?');
      expect(message.role, MessageRole.user);
      expect(message.timestamp, DateTime(2024, 6, 10, 12, 0));
    });

    test('MessageRole enum covers all roles', () {
      expect(MessageRole.values.length, 3);
      expect(MessageRole.values, contains(MessageRole.user));
      expect(MessageRole.values, contains(MessageRole.assistant));
      expect(MessageRole.values, contains(MessageRole.system));
    });

    test('assistant message is valid', () {
      final message = ChatMessage(
        id: 'msg-2',
        analysisId: 'analysis-1',
        content: 'The main threats are SQL injection and XSS.',
        role: MessageRole.assistant,
        timestamp: DateTime(2024, 6, 10, 12, 1),
      );

      expect(message.role, MessageRole.assistant);
      expect(message.content, isNotEmpty);
    });
  });
}
