// // lib/src/feature/chat/model/conversation_dto.dart
// import 'package:coment_app/src/feature/auth/models/user_dto.dart';
// import 'package:coment_app/src/feature/chat/model/chat_message_dto.dart';

// class ConversationDTO {
//   final int id;
//   final String? title;
//   final ChatMessageDTO? lastMessage;
//   final DateTime? lastMessageDate;
//   final UserDTO? partner;
//   final int? companyId;

//   ConversationDTO({
//     required this.id,
//     this.title,
//     this.lastMessage,
//     this.lastMessageDate,
//      this.partner,
//      this.companyId,
//   });

//   factory ConversationDTO.fromJson(Map<String, dynamic> json) {
//     final lastMessageRaw = json['lastMessage'];
//     ChatMessageDTO? parsedMessage;

//     if (lastMessageRaw is Map<String, dynamic>) {
//       parsedMessage = ChatMessageDTO.fromJson(lastMessageRaw);
//     } else if (lastMessageRaw is String) {
//       // Создаем "заглушку" сообщения из строки
//       parsedMessage = ChatMessageDTO(
//         id: 0,
//         content: lastMessageRaw,
//         createdAt: json['lastMessageDate'] != null
//             ? DateTime.parse(json['lastMessageDate'] as String)
//             : DateTime.now(),
//         // Исправлено: добавляем обязательного отправителя
//         sender: const UserDTO(
//           id: 0,
//           email: '',
//           name: 'System', // Или любое дефолтное имя
//         ),
//       );
//     }

//     return ConversationDTO(
//       id: json['id'] as int? ?? 0,
//       title: json['title'] as String?,
//       lastMessage: parsedMessage,
//       lastMessageDate: json['lastMessageDate'] != null 
//           ? DateTime.tryParse(json['lastMessageDate']) 
//           : null,
//       companyId: json['companyId'],
//       // Парсим партнера, если он есть
//       partner: json['partner'] != null 
//           ? UserDTO.fromJson(json['partner']) 
//           : null,
//     );
//   }
// }


import 'package:coment_app/src/feature/auth/models/user_dto.dart';
import 'package:coment_app/src/feature/chat/model/chat_message_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_dto.freezed.dart';
part 'conversation_dto.g.dart';

// @freezed
// class ConversationDTO with _$ConversationDTO {
//   const factory ConversationDTO({
//     required int id,
//     String? title,
//     ChatMessageDTO? lastMessage,
//     DateTime? lastMessageDate,
//     UserDTO? partner,
//     int? companyId,
//   }) = _ConversationDTO;

//   factory ConversationDTO.fromJson(Map<String, dynamic> json) =>
//       _$ConversationDTOFromJson(json);
// }
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
  }) = _ConversationDTO;

  factory ConversationDTO.fromJson(Map<String, dynamic> json) =>
      _$ConversationDTOFromJson(json);
}

// Кастомный парсер для lastMessage
ChatMessageDTO? _chatMessageFromJson(dynamic json) {
  if (json == null) return null;
  if (json is Map<String, dynamic>) {
    return ChatMessageDTO.fromJson(json);
  } else if (json is String) {
    // Создаём "заглушку" для строкового lastMessage
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
  if (json is Map<String, dynamic>) return UserDTO.fromJson(json);
  return null;
}
