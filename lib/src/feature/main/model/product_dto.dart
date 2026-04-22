// ignore_for_file: invalid_annotation_target

import 'package:coment_app/src/feature/main/model/feedback_dto.dart';
import 'package:coment_app/src/feature/main/model/main_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_dto.freezed.dart';
part 'product_dto.g.dart';

@freezed
class ProductDTO with _$ProductDTO {
  const ProductDTO._();
  const factory ProductDTO({
    int? id,
    String? name,
    String? image,
    @JsonKey(name: 'imageUrl')
    String? imageUrl, // Добавляем для редактирования (ключ "imageUrl")
    @JsonKey(name: 'logoUrl') String? logoUrl,
    String? branch,
    @JsonKey(name: 'organisation_phone') String? organisationPhone,
    @JsonKey(name: 'phone') String? phone,
    @JsonKey(name: 'website_url') String? websiteUrl,
    @JsonKey(name: 'website') String? website,
    String? address,
    CatalogDTO? catalog,
    SubCatalogDTO? subCatalog,
    CountryDTO? country,
    CityDTO? city,
    double? rating,
    @JsonKey(name: 'feedback_count') int? feedbackCount,
    @JsonKey(name: 'rating_counts') RatingDTO? ratingCounts,
    @JsonKey(name: 'feedback_images') List<String>? feedbackImages,
    List<BranchesDTO>? branches,
    List<FeedbackDTO>? feedback,
    @JsonKey(name: 'created_at') String? createdAt,
    bool? isVerified,
    int? ownerId,
  }) = _ProductDTO;

  factory ProductDTO.fromJson(Map<String, dynamic> json) =>
      _$ProductDTOFromJson(json);


      // Этот геттер вернет первую попавшуюся не пустую ссылку
  String get displayImage => image ?? imageUrl ?? logoUrl ?? '';
  String get displayPhone => organisationPhone ?? phone  ?? '';
  String get displayWebsite => websiteUrl ?? website  ?? '';
}

@freezed
class BranchesDTO with _$BranchesDTO {
  const factory BranchesDTO({
    int? id,
    String? name,
    String? image,
    String? branch,
    CatalogDTO? catalog,
    SubCatalogDTO? subCatalog,
    CountryDTO? country,
    CityDTO? city,
    int? rating,
    @JsonKey(name: 'feedback_count') int? feedbackCount,
    List<FeedbackDTO>? feedback,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _BranchesDTO;

  factory BranchesDTO.fromJson(Map<String, dynamic> json) =>
      _$BranchesDTOFromJson(json);
}

@freezed
class RatingDTO with _$RatingDTO {
  const factory RatingDTO({
    @JsonKey(name: '1') int? one,
    @JsonKey(name: '2') int? two,
    @JsonKey(name: '3') int? three,
    @JsonKey(name: '4') int? four,
    @JsonKey(name: '5') int? five,
  }) = _RatingDTO;

  factory RatingDTO.fromJson(Map<String, dynamic> json) =>
      _$RatingDTOFromJson(json);
}
