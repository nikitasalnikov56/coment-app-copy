import 'package:coment_app/src/core/rest_client/rest_client.dart';
import 'package:coment_app/src/core/utils/talker_logger_util.dart';
import 'package:coment_app/src/feature/main/model/feedback_dto.dart';
import 'package:coment_app/src/feature/main/model/main_dto.dart';
import 'package:coment_app/src/feature/main/model/product_dto.dart';
import 'package:flutter/foundation.dart';

abstract interface class IMainRemoteDS {
  Future<MainDTO> dictionary();

  Future<List<SubCatalogDTO>> subcatalogList({required int catalogId});

  Future<List<CityDTO>> cityList({required int countryId});

  Future<List<ProductDTO>> productList({
    required int subcatalogId,
    String? sort,
    int? cityId,
    int? countryId,
  });

  Future<List<ProductDTO>> popularProductList({int? cityId});

  Future<List<FeedbackDTO>> popularFeedbackList({int? cityId});
}

class MainRemoteDSImpl implements IMainRemoteDS {
  const MainRemoteDSImpl({
    required this.restClient,
  });
  final IRestClient restClient;

  @override
  Future<MainDTO> dictionary() async {
    try {
      final Map<String, dynamic> response = await restClient.get(
        '/dictionary',
        queryParams: {},
      );

      return MainDTO.fromJson(response);
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#main page dictionary - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<List<SubCatalogDTO>> subcatalogList({required int catalogId}) async {
    try {
      final Map<String, dynamic> response = await restClient.get(
        '/main/get-subCatalog/$catalogId',
        queryParams: {},
      );

      if (response['data'] == null) {
        throw Exception();
      }
      final list = await compute<List<dynamic>, List<SubCatalogDTO>>(
        (list) => list
            .map(
              (e) => SubCatalogDTO.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
        response['data'] as List,
      );
      return list;
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#getSubcatalogList - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<List<CityDTO>> cityList({required int countryId}) async {
    try {
      final Map<String, dynamic> response = await restClient.get(
        '/main/get-city/$countryId',
        queryParams: {},
      );

      if (response['data'] == null) {
        throw Exception();
      }
      final list = await compute<List<dynamic>, List<CityDTO>>(
        (list) => list
            .map(
              (e) => CityDTO.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
        response['data'] as List,
      );
      return list;
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#getCityList - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<List<ProductDTO>> productList({
    required int subcatalogId,
    String? sort,
    int? cityId,
    int? countryId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;
      if (cityId != null && cityId != 0) queryParams['city_id'] = cityId;
      if (countryId != null && countryId != 0) queryParams['country_id'] = countryId;

      final Map<String, dynamic> response = await restClient.get(
        '/main/items/$subcatalogId',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response['data'] == null) {
        throw Exception();
      }
      final list = await compute<List<dynamic>, List<ProductDTO>>(
        (list) => list
            .map(
              (e) => ProductDTO.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
        response['data'] as List,
      );

      return list;
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#getProductList - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<List<ProductDTO>> popularProductList({int? cityId}) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (cityId != null && cityId != 0) queryParams['city_id'] = cityId;

      final Map<String, dynamic> response = await restClient.get(
        '/main/popular',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response['data'] == null) {
        throw Exception();
      }
      final list = await compute<List<dynamic>, List<ProductDTO>>(
        (list) => list
            .map(
              (e) => ProductDTO.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
        response['data'] as List,
      );
      return list;
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#getPopularProducts - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<List<FeedbackDTO>> popularFeedbackList({int? cityId}) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (cityId != null && cityId != 0) queryParams['city_id'] = cityId;

      final Map<String, dynamic> response = await restClient.get(
        '/main/popular-feedback',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response['data'] == null) {
        throw Exception();
      }
      final list = await compute<List<dynamic>, List<FeedbackDTO>>(
        (list) => list
            .map(
              (e) => FeedbackDTO.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
        response['data'] as List,
      );
      return list;
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#getPopularFeedbacks - $e', e, st);
      rethrow;
    }
  }
}
