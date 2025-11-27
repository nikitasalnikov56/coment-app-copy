import 'package:coment_app/src/feature/catalog/data/catalog_remote_ds.dart';
import 'package:coment_app/src/feature/catalog/data/catalog_repository.dart';
import 'package:coment_app/src/feature/settings/data/app_settings_datasource.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:coment_app/src/core/rest_client/rest_client.dart';
import 'package:coment_app/src/core/rest_client/src/dio_rest_client/src/dio_client.dart';
import 'package:coment_app/src/core/rest_client/src/dio_rest_client/src/interceptor/dio_interceptor.dart';
import 'package:coment_app/src/core/rest_client/src/dio_rest_client/src/rest_client_dio.dart';
import 'package:coment_app/src/feature/auth/data/auth_remote_ds.dart';
import 'package:coment_app/src/feature/auth/data/auth_repository.dart';
import 'package:coment_app/src/feature/auth/database/auth_dao.dart';
import 'package:coment_app/src/feature/main/data/main_remote_ds.dart';
import 'package:coment_app/src/feature/main/data/main_repository.dart';
import 'package:coment_app/src/feature/profile/data/profile_remote_ds.dart';
import 'package:coment_app/src/feature/profile/data/profile_repository.dart';

abstract class IRepositoryStorage {
  // dao's
  IAuthDao get authDao;
  // ISettingsDao get settingsDao;
  // ITipsDao get tipsDao;

  /// Network
  IRestClient get restClient;

  // Repositories
  // ISettingsRepository get settings;
  IAuthRepository get authRepository;
  IProfileRepository get profileRepository;
  IMainRepository get mainRepository;
  ICatalogRepository get catalogRepository;

  // Data sources
  IAuthRemoteDS get authRemoteDS;
  IProfileRemoteDS get profileRemoteDS;
  IMainRemoteDS get mainRemoteDS;
  ICatalogRemoteDS get catalogRemoteDS;

  void close();
}

class RepositoryStorage implements IRepositoryStorage {
  RepositoryStorage({
    required SharedPreferencesWithCache sharedPreferences,
    required PackageInfo packageInfo,
    required AppSettingsDatasource appSettingsDatasource,
  })  : _sharedPreferences = sharedPreferences,
        _packageInfo = packageInfo,
        _appSettingsDatasource = appSettingsDatasource;
  final SharedPreferencesWithCache _sharedPreferences;
  final PackageInfo _packageInfo;
  IRestClient? _restClient;
  final AppSettingsDatasource _appSettingsDatasource;

  @override
  Future<void> close() async {
    _restClient = null;
    // _portalRestClient = null;
    // _marketplaceRestClient = null;
    // _gamificationRestClient = null;
  }

  ///
  /// Network
  ///
  // @override
  // IRestClient get restClient => _restClient ??= RestClientDio(
  //       // baseUrl: 'http://localhost:3001/api/v1/',
  //       // baseUrl: 'http://46.226.123.73/api/',
  //       baseUrl: 'http://10.0.2.2:3001/api/v1/',
  //       dioClient: DioClient(
  //         // baseUrl: 'http://localhost:3001/api/v1/',
  //         baseUrl: 'http://10.0.2.2:3001/api/v1/',
  //         // baseUrl: 'http://46.226.123.73/api/',
  //         interceptor: const DioInterceptor(),
  //         authDao: authDao,
  //         packageInfo: _packageInfo, appSettingsDS: _appSettingsDatasource,
  //         // settings: SettingsDao(sharedPreferences: sharedPreferences),
  //       ),
  //     );

  @override
  IRestClient get restClient => _restClient ??= RestClientDio(
        baseUrl: 'http://10.0.2.2:3001/api/v1/',
        // baseUrl: 'http://192.168.0.100:3001/api/v1/',
        dioClient: DioClient(
          baseUrl: 'http://10.0.2.2:3001/api/v1/',
          // baseUrl: 'http://192.168.0.100:3001/api/v1/',
          interceptor: DioInterceptor(), // ← обычный, без параметров
          authDao: authDao,
          packageInfo: _packageInfo,
          appSettingsDS: _appSettingsDatasource,
        ),
      );

  ///
  /// Repositories
  ///
  @override
  IAuthRepository get authRepository => AuthRepositoryImpl(
        remoteDS: authRemoteDS,
        authDao: authDao,
      );

  @override
  IProfileRepository get profileRepository => ProfileRepositoryImpl(
        remoteDS: profileRemoteDS,
        authDao: authDao,
        authRepository: authRepository,
      );

  @override
  IMainRepository get mainRepository => MainRepositoryImpl(
        remoteDS: mainRemoteDS,
      );

  @override
  ICatalogRepository get catalogRepository =>
      CatalogRepositoryImpl(remoteDS: catalogRemoteDS);

  ///
  /// Remote datasources
  ///
  @override
  IAuthRemoteDS get authRemoteDS => AuthRemoteDSImpl(
        restClient: restClient,
      );

  @override
  IProfileRemoteDS get profileRemoteDS => ProfileRemoteDSImpl(
        restClient: restClient,
      );

  @override
  IMainRemoteDS get mainRemoteDS => MainRemoteDSImpl(
        restClient: restClient,
      );

  @override
  ICatalogRemoteDS get catalogRemoteDS =>
      CatalogRemoteDsImpl(restClient: restClient);

  ///
  /// Data Access Object
  ///
  @override
  IAuthDao get authDao => AuthDao(sharedPreferences: _sharedPreferences);
}
