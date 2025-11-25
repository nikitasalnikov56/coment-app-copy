// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback_payload.freezed.dart';
part 'feedback_payload.g.dart';

@freezed
class FeedbackPayload with _$FeedbackPayload {
  const factory FeedbackPayload({
    @JsonKey(name: 'product_id', includeIfNull: false) int? productId,
    @JsonKey(includeIfNull: false) int? rating,
    @JsonKey(name:'text', includeIfNull: false) String? comment,
  }) = _FeedbackPayload;

  factory FeedbackPayload.fromJson(Map<String, dynamic> json) => _$FeedbackPayloadFromJson(json);
}
