// lib/src/feature/profile/models/response/verification_response.dart
import 'package:coment_app/src/feature/auth/models/user_dto.dart';
import 'package:coment_app/src/feature/main/model/product_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'verification_response.freezed.dart';
part 'verification_response.g.dart';

@freezed
class VerificationResponse with _$VerificationResponse {
  const factory VerificationResponse({
    required int id,
    // required int companyId,
    required UserDTO user,
    required ProductDTO company,
    required List<String> documentUrls,
    String? status,
    String? createdAt,
  }) = _VerificationResponse;

  factory VerificationResponse.fromJson(Map<String, dynamic> json) =>
      _$VerificationResponseFromJson(json);
}