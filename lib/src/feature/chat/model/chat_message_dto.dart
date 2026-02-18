import 'package:coment_app/src/feature/auth/models/user_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_dto.freezed.dart';
part 'chat_message_dto.g.dart';


@freezed
class ChatMessageDTO with _$ChatMessageDTO {
  const factory ChatMessageDTO({
    
    required int id,
    required String content,
    required DateTime createdAt,
    required UserDTO sender,
     int? conversationId,
     ChatMessageDTO? replyTo,
  }) = _ChatMessageDTO;

  factory ChatMessageDTO.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageDTOFromJson(json);
}

