// ignore_for_file: invalid_annotation_target

import 'package:coment_app/src/feature/main/model/main_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed
class UserDTO with _$UserDTO {
  const factory UserDTO({
    @JsonKey(defaultValue: -1) int? id,
    @JsonKey(name: 'name') String? name,
    String? email,
    @JsonKey(name: 'phoneNumber')
    String? phone,
    @JsonKey(name: 'avatar_url')
    String? avatar,
    CityDTO? city,
    LanguageDTO? language,
    int? rating,
    @JsonKey(name: 'city_name') String? cityName,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'access_token') String? accessToken,
    @JsonKey(name: 'device_token') String? deviceToken,
    @JsonKey(name: 'device_type') String? deviceType,
    @JsonKey(name: 'refresh_token') String? refreshToken,
     // 👇 ДОБАВИЛ
    // @JsonKey(name: 'warningCount') int? warningCount,
  }) = _UserDTO;
  factory UserDTO.fromJson(Map<String, dynamic> json) => _$UserDTOFromJson(json);
}
