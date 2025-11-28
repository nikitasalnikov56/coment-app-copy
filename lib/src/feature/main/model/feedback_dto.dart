// ignore_for_file: invalid_annotation_target

import 'package:coment_app/src/feature/auth/models/user_dto.dart';
import 'package:coment_app/src/feature/main/model/main_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback_dto.freezed.dart';
part 'feedback_dto.g.dart';

DateTime? _fromJsonDateTime(String? dateString) {
  if (dateString == null) return null;

  // Пробуем стандартный парсинг
  DateTime? parsed = DateTime.tryParse(dateString);
  if (parsed != null) return parsed;

  // Резервный парсинг: убираем миллисекунды и 'Z', заменяем 'T' на пробел
  String cleaned = dateString
      .replaceFirst(RegExp(r'\.\d{3}Z$'), '') // убираем .123Z
      .replaceAll('T', ' '); // заменяем T на пробел
  return DateTime.tryParse(cleaned);
}

String? _toJsonDateTime(DateTime? date) {
  return date?.toIso8601String();
}

@freezed
class FeedbackDTO with _$FeedbackDTO {
  const factory FeedbackDTO({
    required int? id,
    required UserDTO? user,
    required FeedbackItemDTO? item,
    @JsonKey(name: 'comment')
    required String? comment,
    required int? rating,
    String? image,
    List<ImageDTO>? images,
    @JsonKey(name: 'likes')
    int? likes,
    @JsonKey(name: 'dislikes')
    int? dislikes,
    int? views,
    @JsonKey(
      name: 'created_at',
      fromJson: _fromJsonDateTime,
      toJson: _toJsonDateTime,
    )
    DateTime? createdAt,
    @JsonKey(name: 'is_like') int? isLike,
    @JsonKey(name: 'is_dislike') int? isDislike,
    @JsonKey(name: 'replies_count') int? repliesCount,
     @JsonKey(name: 'replies')  // удостовериться в правильности ключа
    List<RepliesDTO>? replies,
     // 👇 ДОБАВИЛИ ЭТО
    // @JsonKey(name: 'wasToxic') bool? wasToxic,
  }) = _FeedbackDTO;

  factory FeedbackDTO.fromJson(Map<String, dynamic> json) =>
      _$FeedbackDTOFromJson(json);
}

@freezed
class FeedbackItemDTO with _$FeedbackItemDTO {
  const factory FeedbackItemDTO({
    required int? id,
    required String? name,
    // required String? branch,
    required CatalogDTO? catalog,
    required SubCatalogDTO? subCatalog,
    required CountryDTO? country,
    required CityDTO? city,
    // required int? rating,
    @JsonKey(name: 'feedback_count') int? feedbackCount,
  }) = _FeedbackItemDTO;

  factory FeedbackItemDTO.fromJson(Map<String, dynamic> json) =>
      _$FeedbackItemDTOFromJson(json);
}

@freezed
class ImageDTO with _$ImageDTO {
  const factory ImageDTO({
    required int? id,
    required String? image,
  }) = _ImageDTO;

  factory ImageDTO.fromJson(Map<String, dynamic> json) =>
      _$ImageDTOFromJson(json);
}

@freezed
class RepliesDTO with _$RepliesDTO {
  const factory RepliesDTO({
    required int? id,
    required UserDTO? user,
    required String? coment,
    @JsonKey(name: 'parent_id') int? parentId,
    @JsonKey(name: 'feedback_id') int? feedbackId,
    @JsonKey(
      name: 'createdAt',
      fromJson: _fromJsonDateTime,
      toJson: _toJsonDateTime,
    )
    DateTime? createdAt,
    @JsonKey(name: 'text') required String? comment,
    List<ReplyDTO>? reply,
  }) = _RepliesDTO;

  factory RepliesDTO.fromJson(Map<String, dynamic> json) =>
      _$RepliesDTOFromJson(json);
}

@freezed
class ReplyDTO with _$ReplyDTO {
  const factory ReplyDTO({
    required int? id,
    required UserDTO? user,
    required String? coment,
    @JsonKey(name: 'parent_id') int? parentId,
    @JsonKey(name: 'feedback_id') int? feedbackId,
    @JsonKey(
      name: 'createdAt',
      fromJson: _fromJsonDateTime,
      toJson: _toJsonDateTime,
    )
    DateTime? createdAt,
    @JsonKey(name: 'text') required String? comment,
    List<ReplyTwoDTO>? reply,
     @JsonKey(name: 'helpfulCount') int? helpfulCount,
  }) = _ReplyDTO;

  factory ReplyDTO.fromJson(Map<String, dynamic> json) =>
      _$ReplyDTOFromJson(json);
}

@freezed
class ReplyTwoDTO with _$ReplyTwoDTO {
  const factory ReplyTwoDTO({
    required int? id,
    required UserDTO? user,
    required String? coment,
    @JsonKey(name: 'parent_id') int? parentId,
    @JsonKey(name: 'feedback_id') int? feedbackId,
    @JsonKey(
      name: 'createdAt',
      fromJson: _fromJsonDateTime,
      toJson: _toJsonDateTime,
    )
    DateTime? createdAt,
     @JsonKey(name: 'text') 
    required String? comment,
    List<ReplyDTO>? reply,
  }) = _ReplyTwoDTO;

  factory ReplyTwoDTO.fromJson(Map<String, dynamic> json) =>
      _$ReplyTwoDTOFromJson(json);
}
