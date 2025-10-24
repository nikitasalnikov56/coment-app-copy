import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_dto.freezed.dart';
part 'catalog_dto.g.dart';

// @freezed
// class CatalogItemDTO with _$CatalogItemDTO {
//   const factory CatalogItemDTO({
//     int? id,
//     String? name,
//     String? image,
//     String? branch,
//     CatalogDTO? catalog,
//     @JsonKey(name: 'subCatalog') SubCatalogDTO? subCatalog,
//     CountryDTO? country,
//     CityDTO? city,
//     double? rating,
//     @JsonKey(name: 'created_at') String? createdAt,
//     @JsonKey(name: 'feedback_count') int? feedbackCount,
//     List<FeedbackDTO>? feedback,
//   }) = _CatalogItemDTO;

//   factory CatalogItemDTO.fromJson(Map<String, dynamic> json) => _$CatalogItemDTOFromJson(json);
// }

// @freezed
// class CatalogDTO with _$CatalogDTO {
//   const factory CatalogDTO({
//     int? id,
//     String? name,
//     @JsonKey(name: 'name_kk') String? nameKk,
//     @JsonKey(name: 'name_en') String? nameEn,
//     @JsonKey(name: 'name_uz') String? nameUz,
//     @JsonKey(name: 'created_at') String? createdAt,
//     String? image,
//   }) = _CatalogDTO;

//   factory CatalogDTO.fromJson(Map<String, dynamic> json) => _$CatalogDTOFromJson(json);
// }

// @freezed
// class SubCatalogDTO with _$SubCatalogDTO {
//   const factory SubCatalogDTO({
//     int? id,
//     String? name,
//     @JsonKey(name: 'name_kk') String? nameKk,
//     @JsonKey(name: 'name_en') String? nameEn,
//     @JsonKey(name: 'name_uz') String? nameUz,
//     @JsonKey(name: 'created_at') String? createdAt,
//   }) = _SubCatalogDTO;

//   factory SubCatalogDTO.fromJson(Map<String, dynamic> json) => _$SubCatalogDTOFromJson(json);
// }

// @freezed
// class CountryDTO with _$CountryDTO {
//   const factory CountryDTO({
//     int? id,
//     String? name,
//   }) = _CountryDTO;

//   factory CountryDTO.fromJson(Map<String, dynamic> json) => _$CountryDTOFromJson(json);
// }

// @freezed
// class CityDTO with _$CityDTO {
//   const factory CityDTO({
//     int? id,
//     String? name,
//     CountryDTO? country,
//   }) = _CityDTO;

//   factory CityDTO.fromJson(Map<String, dynamic> json) => _$CityDTOFromJson(json);
// }

// @freezed
// class FeedbackDTO with _$FeedbackDTO {
//   const factory FeedbackDTO({
//     int? id,
//     UserrDTO? user,
//     CatalogItemDTO? item,
//     String? comment,
//     double? rating,
//     String? image,
//     int? likes,
//     int? dislikes,
//     int? views,
//     @JsonKey(name: 'created_at') String? createdAt,
//     @JsonKey(name: 'is_like') bool? isLike,
//     @JsonKey(name: 'is_dislike') bool? isDislike,
//     List? images,
//     List? replies,
//   }) = _FeedbackDTO;

//   factory FeedbackDTO.fromJson(Map<String, dynamic> json) =>
//       _$FeedbackDTOFromJson(json);
// }

// @freezed
// class UserrDTO with _$UserrDTO {
//   const factory UserrDTO({
//     int? id,
//     String? name,
//     String? email,
//     String? avatar,
//     double? rating,
//     @JsonKey(name: 'access_token') String? accessToken,
//     @JsonKey(name: 'device_type') String? deviceType,
//     @JsonKey(name: 'device_token') String? deviceToken,
//     @JsonKey(name: 'created_at') String? createdAt,
//   }) = _UserrDTO;

//   factory UserrDTO.fromJson(Map<String, dynamic> json) => _$UserrDTOFromJson(json);
// }

@freezed
class ComplainDTO with _$ComplainDTO {
  const factory ComplainDTO({
    int? id,
    String? text,
    String? type,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'created_at') String? createdAt,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ComplainDTO;

  factory ComplainDTO.fromJson(Map<String, dynamic> json) => _$ComplainDTOFromJson(json);
}
