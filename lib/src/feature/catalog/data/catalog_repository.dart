import 'dart:io';

import 'package:coment_app/src/core/rest_client/models/basic_response.dart';
import 'package:coment_app/src/feature/catalog/data/catalog_remote_ds.dart';
import 'package:coment_app/src/feature/catalog/model/catalog_dto.dart';
import 'package:coment_app/src/feature/catalog/model/feedback_payload.dart';
import 'package:coment_app/src/feature/main/model/feedback_dto.dart';
import 'package:coment_app/src/feature/main/model/product_dto.dart';

abstract interface class ICatalogRepository {
  Future<ProductDTO> productInfo({required int id});

  Future<FeedbackDTO> userFeedback({required int id, required String isView});

  Future<ComplainDTO> complain({required String text, required int feedId, required String type});

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

  Future<List<ProductDTO>> searchProductList({required String search});

  Future<Map<String, dynamic>> replyFeedback({required int feedbackId, required String comment, int? parentId});

  Future<BasicResponse> like({required int feedbackId, required String type});

  Future<BasicResponse> dislike({required int feedbackId});

    Future<Map<String, dynamic>> translateReview(
      {required int reviewId, required String targetLang});
      
  Future<Map<String, dynamic>> translateReply(
      {required int replyId, required String targetLang});
}

class CatalogRepositoryImpl implements ICatalogRepository {
  const CatalogRepositoryImpl({
    required ICatalogRemoteDS remoteDS,
  }) : _remoteDS = remoteDS;
  final ICatalogRemoteDS _remoteDS;

  @override
  Future<ProductDTO> productInfo({required int id}) async {
    try {
      final response = await _remoteDS.productInfo(id: id);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ComplainDTO> complain({required String text, required int feedId, required String type}) async {
    try {
      return await _remoteDS.complain(text: text, feedId: feedId, type: type);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<FeedbackDTO> userFeedback({required int id, required String isView}) async {
    try {
      final response = await _remoteDS.userFeedback(id: id, isView: isView);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> createFeedback({required FeedbackPayload feedbackPayload, List<File>? imageFeedback}) async {
    try {
      return await _remoteDS.createFeedback(feedbackPayload: feedbackPayload, imageFeedback: imageFeedback);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ProductDTO>> searchProductList({required String search}) async {
    try {
      final response = await _remoteDS.searchProductList(search: search);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
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
      String? nameSubCatalog}) async {
    try {
      final response = await _remoteDS.createNewProduct(
          cityId: cityId,
          countryId: countryId,
          name: name,
          address: address,
          organisationPhone: organisationPhone,
          websiteUrl: websiteUrl,
          catalogId: catalogId,
          subCatalogId: subCatalogId,
          comment: comment,
          rating: rating,
          image: image,
          imageFeedback: imageFeedback,
          nameSubCatalog: nameSubCatalog);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> replyFeedback({required int feedbackId, required String comment, int? parentId}) async {
    try {
      final response = await _remoteDS.replyFeedback(feedbackId: feedbackId, comment: comment, parentId: parentId);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BasicResponse> like({required int feedbackId, required String type}) async {
    try {
      final response = await _remoteDS.like(feedbackId: feedbackId, type: type);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BasicResponse> dislike({required int feedbackId}) async {
    try {
      final response = await _remoteDS.dislike(feedbackId: feedbackId);
      return response;
    } catch (e) {
      rethrow;
    }
  }

@override
 Future<Map<String, dynamic>> translateReview(
      {required int reviewId, required String targetLang}) async{
        try {
          final response = await _remoteDS.translateReview(reviewId: reviewId, targetLang: targetLang);
          return response;
        } catch (e) {
          rethrow;
        }
      }

@override
Future<Map<String, dynamic>> translateReply(
      {required int replyId, required String targetLang}) async{
        try {
           final response = await _remoteDS.translateReply(replyId: replyId, targetLang: targetLang);
           return response;
        } catch (e) {
          rethrow;
        }
      }

}
