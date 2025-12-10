import 'dart:io';

import 'package:coment_app/src/core/rest_client/models/basic_response.dart';
import 'package:coment_app/src/core/rest_client/rest_client.dart';
import 'package:coment_app/src/core/utils/talker_logger_util.dart';
import 'package:coment_app/src/feature/catalog/model/catalog_dto.dart';
import 'package:coment_app/src/feature/catalog/model/feedback_payload.dart';
import 'package:coment_app/src/feature/main/model/feedback_dto.dart';
import 'package:coment_app/src/feature/main/model/product_dto.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

abstract interface class ICatalogRemoteDS {
  Future<ProductDTO> productInfo({required int id});

  Future<FeedbackDTO> userFeedback({required int id, required String isView});

  Future<Map<String, dynamic>> createFeedback({
    required FeedbackPayload feedbackPayload,
    List<File>? imageFeedback,
  });

  Future<BasicResponse> createNewProduct(
      {required int cityId,
      required int countryId,
      File? image,
      required String name,
      required String address,
      required String organisationPhone,
      required String websiteUrl,
      required int catalogId,
      int? subCatalogId,
      required String comment,
      required int rating,
      List<File>? imageFeedback,
      String? nameSubCatalog});

  Future<ComplainDTO> complain(
      {required String text, required int feedId, required String type});

  Future<List<ProductDTO>> searchProductList({required String search});

  Future<Map<String, dynamic>> replyFeedback(
      {required int feedbackId, required String comment, int? parentId});

  Future<BasicResponse> like({required int feedbackId, required String type});

  Future<BasicResponse> dislike({required int feedbackId});

  Future<Map<String, dynamic>> translateReview(
      {required int reviewId, required String targetLang});

  Future<Map<String, dynamic>> translateReply(
      {required int replyId, required String targetLang});
}

class CatalogRemoteDsImpl implements ICatalogRemoteDS {
  const CatalogRemoteDsImpl({
    required this.restClient,
  });
  final IRestClient restClient;

  @override
  Future<ProductDTO> productInfo({required int id}) async {
    try {
      final Map<String, dynamic> response = await restClient.get(
        'main/show-item/$id',
        queryParams: {},
      );
      return ProductDTO.fromJson(response);
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#product info page- $e', e, st);
      rethrow;
    }
  }

  @override
  Future<ComplainDTO> complain(
      {required String text, required int feedId, required String type}) async {
    try {
      final Map<String, dynamic> response = await restClient.post(
        queryParams: {},
        'feedback/complaint/$feedId',
        body: {'text': text, 'type': type},
      );
      return ComplainDTO.fromJson(response);
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#catalog page complain - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<FeedbackDTO> userFeedback(
      {required int id, required String isView}) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (isView != '' && isView.isNotEmpty) queryParams['is_view'] = isView;

      final Map<String, dynamic> response = await restClient.get(
        'feedback/show/$id',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );
      return FeedbackDTO.fromJson(response);
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#catalog page userFeedback - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<List<ProductDTO>> searchProductList({required String search}) async {
    try {
      final Map<String, dynamic> response = await restClient.get(
        '/companies/search/',
        queryParams: {'q': search},
      );

      if (response['items'] == null) {
        throw Exception();
      }
      final list = await compute<List<dynamic>, List<ProductDTO>>(
        (list) => list
            .map(
              (e) => ProductDTO.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
        response['items'] as List,
      );
      return list;
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#getSearchProductList - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> createFeedback({
    required FeedbackPayload feedbackPayload,
    List<File>? imageFeedback,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'text': feedbackPayload.comment,
        'rating': feedbackPayload.rating,
      };

      final FormData formData = FormData.fromMap(data);

      if (imageFeedback != null && imageFeedback.isNotEmpty) {
        for (int i = 0; i < imageFeedback.length; i++) {
          formData.files.add(
            MapEntry(
              'image_feedback[]',
              await MultipartFile.fromFile(imageFeedback[i].path),
            ),
          );
        }
      }

      final Map<String, dynamic> response = await restClient.post(
        // 'feedback/${feedbackPayload.productId}/create',
        'companies/${feedbackPayload.productId}/reviews',
        body: formData,
      );
      print('Response data = $response');

      return response;
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#catalog page crate - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<BasicResponse> createNewProduct({
    required int cityId,
    required int countryId,
    File? image,
    required String name,
    required String address,
    required String organisationPhone,
    required String websiteUrl,
    required int catalogId,
    int? subCatalogId,
    required String comment,
    required int rating,
    List<File>? imageFeedback,
    String? nameSubCatalog,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (cityId != 0) data['city_id'] = cityId;
      if (countryId != 0) data['country_id'] = countryId;
      if (name.isNotEmpty) data['name'] = name;
      if (address.isNotEmpty) data['address'] = address;
      if (organisationPhone.isNotEmpty) {
        data['organisation_phone'] = organisationPhone;
      }
      if (websiteUrl.isNotEmpty) {
        String url = websiteUrl.trim();
        if (!url.startsWith('http://') && !url.startsWith('https://')) {
          url = 'https://$url';
        }
        data['website_url'] = url;
        }
      if (catalogId != 0) data['catalog_id'] = catalogId;
      if (subCatalogId != null && subCatalogId > 0) data['sub_catalog_id'] = subCatalogId;
      if (comment.isNotEmpty) data['comment'] = comment;
      if (rating != 0) data['rating'] = rating;
      if ((nameSubCatalog ?? '').isNotEmpty) {
        data['name_sub_catalog'] = nameSubCatalog;
      }

      final FormData formData = FormData.fromMap(data);

      if (image != null) {
        formData.files.add(
          MapEntry('image', await MultipartFile.fromFile(image.path)),
        );
      }
      if (imageFeedback != null && imageFeedback.isNotEmpty) {
        for (int i = 0; i < imageFeedback.length; i++) {
          formData.files.add(
            MapEntry(
              'image_feedback[]',
              await MultipartFile.fromFile(imageFeedback[i].path),
            ),
          );
        }
      }

      // final Map<String, dynamic> response = await restClient.post(
      //   'feedback/create-item',
      //   body: formData,
      // );
      final Map<String, dynamic> response = await restClient.post(
        'catalog/create-item',
        body: formData,
      );

      return BasicResponse.fromJson(response);
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#create new product - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> replyFeedback(
      {required int feedbackId, required String comment, int? parentId}) async {
    try {
      final Map<String, dynamic> response = await restClient
          .post('/reviews/$feedbackId/reply', body: {
        'replyText': comment,
        if (parentId != null) 'parent_id': parentId
      });

      return response;
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#write reply comment - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<BasicResponse> like(
      {required int feedbackId, required String type}) async {
    try {
      final body = {'isHelpful': type == 'like'};
      final Map<String, dynamic> response = await restClient
          // .post('/feedback/like/$feedbackId', body: {'type': type});
          .post('/reviews/$feedbackId/rate', body: body);

      return BasicResponse.fromJson(response);
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#like comment - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<BasicResponse> dislike({required int feedbackId}) async {
    try {
      final body = {'isHelpful': false};
      final Map<String, dynamic> response =
          await restClient.post('/reviews/$feedbackId/rate', body: body);

      return BasicResponse.fromJson(response);
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#dislike comment - $e', e, st);
      rethrow;
    }
  }

// Перевод комментария
  @override
  Future<Map<String, dynamic>> translateReview({
    required int reviewId,
    required String targetLang,
  }) async {
    final response = await restClient.post(
      'reviews/$reviewId/translate',
      body: {'targetLang': targetLang},
    );
    return response;
  }

// Перевод ответа
  @override
  Future<Map<String, dynamic>> translateReply({
    required int replyId,
    required String targetLang,
  }) async {
    final response = await restClient.post(
      'replies/$replyId/translate',
      body: {'targetLang': targetLang},
    );
    return response;
  }
}
