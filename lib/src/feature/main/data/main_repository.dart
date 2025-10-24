
import 'package:coment_app/src/feature/main/data/main_remote_ds.dart';
import 'package:coment_app/src/feature/main/model/feedback_dto.dart';
import 'package:coment_app/src/feature/main/model/main_dto.dart';
import 'package:coment_app/src/feature/main/model/product_dto.dart';

abstract interface class IMainRepository {
  Future<MainDTO> dictionary();

  Future<List<SubCatalogDTO>> subcatalogList({required int catalogId});

  Future<List<ProductDTO>> productList({
    required int subcatalogId,
    String? sort,
    int? cityId,
    int? countryId,
  });

  Future<List<CityDTO>> cityList({required int countryId});

  Future<List<ProductDTO>> popularProductList({int? cityId});

  Future<List<FeedbackDTO>> popularFeedbackList({int? cityId});
}

class MainRepositoryImpl implements IMainRepository {
  const MainRepositoryImpl({
    required IMainRemoteDS remoteDS,
  }) : _remoteDS = remoteDS;
  final IMainRemoteDS _remoteDS;

  @override
  Future<MainDTO> dictionary() async {
    try {
      final user = await _remoteDS.dictionary();
      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SubCatalogDTO>> subcatalogList({required int catalogId}) async {
    try {
      final response = await _remoteDS.subcatalogList(catalogId: catalogId);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CityDTO>> cityList({required int countryId}) async {
    try {
      final response = await _remoteDS.cityList(countryId: countryId);
      return response;
    } catch (e) {
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
      final response =
          await _remoteDS.productList(subcatalogId: subcatalogId, sort: sort, cityId: cityId, countryId: countryId);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ProductDTO>> popularProductList({int? cityId}) async {
    try {
      final response = await _remoteDS.popularProductList(cityId: cityId);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<FeedbackDTO>> popularFeedbackList({int? cityId}) async {
    try {
      final response = await _remoteDS.popularFeedbackList(cityId: cityId);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
