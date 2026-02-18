// lib/src/feature/chat/data/chat_repository.dart
import 'package:coment_app/src/feature/chat/model/chat_message_dto.dart';
import 'package:coment_app/src/feature/chat/model/conversation_dto.dart';

abstract class IChatRepository {
  Stream<List<ChatMessageDTO>> getMessagesStream(int conversationId);
  Future<void> sendMessage(String content, {int? replyToId, int? targetConversationId});
  Future<void> connectToChat(int conversationId, String token);
  Future<void> disconnect();
  Future<void> ensureConnection();
    Future<List<ConversationDTO>> findConversationsForUser(String token);
    // Stream<Map<String, dynamic>> get userStatusStream;
    Stream<Map<int, Map<String, dynamic>>> get userStatusStream ;
    List<ChatMessageDTO> get currentMessages;
    Map<int, Map<String, dynamic>> get currentStatusCache;
    void deleteMessages(List<int> ids);
    void leaveChat();
}