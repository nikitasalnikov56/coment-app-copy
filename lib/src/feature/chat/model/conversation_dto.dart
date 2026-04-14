import 'package:coment_app/src/feature/auth/models/user_dto.dart';
import 'package:coment_app/src/feature/chat/model/chat_message_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_dto.freezed.dart';
part 'conversation_dto.g.dart';

@freezed
class ConversationDTO with _$ConversationDTO {
  const factory ConversationDTO({
    required int id,
    String? title,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _chatMessageFromJson) ChatMessageDTO? lastMessage,
    DateTime? lastMessageDate,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _userFromJson) UserDTO? partner,
    int? companyId,
    List<String>? attachments,
    @Default(0) int unreadCount,
    String? companyName,
  }) = _ConversationDTO;

  factory ConversationDTO.fromJson(Map<String, dynamic> json) =>
      _$ConversationDTOFromJson(json);
}

// Кастомный парсер для lastMessage
ChatMessageDTO? _chatMessageFromJson(dynamic json) {
  if (json == null) return null;

  if (json is Map) {
    // Важно: приводим к Map<String, dynamic> явно перед передачей
    final map = Map<String, dynamic>.from(json);
    // Проверяем, не пустой ли объект пришел
    if (map.isEmpty) return null;
    return ChatMessageDTO.fromJson(map);
  }

  if (json is String) {
    return ChatMessageDTO(
      id: 0,
      content: json,
      createdAt: DateTime.now(),
      sender: const UserDTO(id: 0, email: '', name: 'System'),
    );
  }
  return null;
}

// Кастомный парсер для partner
UserDTO? _userFromJson(dynamic json) {
  if (json == null) return null;

  if (json is Map) {
    final map = Map<String, dynamic>.from(json);
    if (map.isEmpty) return null;
    return UserDTO.fromJson(map);
  }
  return null;
}
