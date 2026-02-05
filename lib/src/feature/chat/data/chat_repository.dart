// lib/src/feature/chat/data/chat_repository.dart
import 'package:coment_app/src/feature/chat/model/chat_message_dto.dart';
import 'package:coment_app/src/feature/chat/model/conversation_dto.dart';

abstract class IChatRepository {
  Stream<List<ChatMessageDTO>> getMessagesStream(int conversationId);
  Future<void> sendMessage(String content);
  Future<void> connectToChat(int conversationId, String token);
  Future<void> disconnect();
    Future<List<ConversationDTO>> findConversationsForUser(String token);
}