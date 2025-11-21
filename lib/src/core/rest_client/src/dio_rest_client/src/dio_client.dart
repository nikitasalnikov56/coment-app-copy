import 'dart:convert';
import 'package:coment_app/src/feature/settings/data/app_settings_datasource.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:coment_app/src/core/utils/talker_logger_util.dart';
import 'package:coment_app/src/feature/auth/database/auth_dao.dart';
import 'package:coment_app/src/feature/auth/models/user_dto.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';

class DioClient {
  factory DioClient({
    required String baseUrl,
    required Interceptor interceptor,
    required IAuthDao authDao,
    required PackageInfo packageInfo,
    required AppSettingsDatasource appSettingsDS,
    Dio? initialDio,
    bool useInterceptorWrapper = true,
  }) =>
      DioClient._internal(
        baseUrl: baseUrl,
        initialDio: initialDio,
        interceptor: interceptor,
        authDao: authDao,
        packageInfo: packageInfo,
        appSettingsDS: appSettingsDS,
        useInterceptorWrapper: useInterceptorWrapper,
      );

  DioClient._internal({
    required String baseUrl,
    required Interceptor interceptor,
    required IAuthDao authDao,
    required PackageInfo packageInfo,
    required AppSettingsDatasource appSettingsDS,
    required Dio? initialDio,
    required bool useInterceptorWrapper,
  }) : dio = initialDio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            )
          ..httpClientAdapter = IOHttpClientAdapter() {
    _initInterceptors(
      dioInterceptor: interceptor,
      authDao: authDao,
      packageInfo: packageInfo,
      appSettingsDS: appSettingsDS,
      useInterceptorWrapper: useInterceptorWrapper,
    );
  }

  final Dio dio;

  void _initInterceptors({
    required Interceptor dioInterceptor,
    required IAuthDao authDao,
    required PackageInfo packageInfo,
    required AppSettingsDatasource appSettingsDS,
    required bool useInterceptorWrapper,
  }) async {
    if (useInterceptorWrapper) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            options.extra['withCredentials'] = true;
            options.extra['dio'] = dio;
            
            options.headers['Access-Control-Allow-Origin'] = '*';
            options.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS';
            options.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, X-Requested-With';

            final appSettings = await appSettingsDS.getAppSettings();
            options.headers['Accept'] = 'application/json';
            options.headers['version'] = packageInfo.version;
            options.headers['Accept-Language'] = appSettings?.locale?.languageCode;
            
            final userStr = authDao.user.value;
            if (userStr != null) {
              final user = UserDTO.fromJson(jsonDecode(userStr) as Map<String, dynamic>);
              if (user.accessToken != null) {
                options.headers['Authorization'] = 'Bearer ${user.accessToken}';
              }
            }

            return handler.next(options);
          },
          onError: (DioException e, handler) async {
            // 🔁 Автоматическое обновление токена при 401, но НЕ для /auth/refresh
            if (e.response?.statusCode == 401 &&
                !e.requestOptions.path.contains('auth/refresh')) {
              try {
                // 1. Берем refresh_token из SecureStorage (самое надежное место)
                const storage = FlutterSecureStorage();
                final currentRefreshToken = await storage.read(key: 'refresh_token');
                
                if (currentRefreshToken == null) {
                    throw Exception('No refresh token in secure storage');
                }

                // 2. Делаем запрос на обновление
                final refreshResponse = await dio.post('auth/refresh', data: {
                   'refresh_token': currentRefreshToken
                });

                final newAccessToken = refreshResponse.data?['access_token'] as String?;
                final newRefreshToken = refreshResponse.data?['refresh_token'] as String?;

                if (newAccessToken != null) {
                  // 3.1. Сохраняем новый REFRESH в SecureStorage (ОБЯЗАТЕЛЬНО!)
                  if (newRefreshToken != null) {
                     await storage.write(key: 'refresh_token', value: newRefreshToken);
                     TalkerLoggerUtil.talker.log('Interceptor: Updated refresh token in SecureStorage');
                  }

                  // 3.2. Обновляем ACCESS в AuthDao (для UI и следующих запросов)
                  final userStr = authDao.user.value;
                  if (userStr != null && userStr != 'null') {
                    final userMap = jsonDecode(userStr) as Map<String, dynamic>;
                    userMap['access_token'] = newAccessToken;
                    
                    // Для синхронизации сохраним и сюда, хотя источник правды SecureStorage
                    if (newRefreshToken != null) {
                        userMap['refresh_token'] = newRefreshToken;
                    }
                    
                    await authDao.user.setValue(jsonEncode(userMap));
                  } else {
                    // Редкий кейс, если юзера нет, но мы обновляемся
                    await authDao.user.setValue(jsonEncode({
                        'access_token': newAccessToken,
                        'refresh_token': newRefreshToken
                    }));
                  }

                  // 4. Повторяем исходный запрос с НОВЫМ токеном
                  final newOptions = e.requestOptions;
                  newOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                  
                  // Важно: создаем новый запрос, чтобы не было проблем с уже закрытым потоком
                  final retryResponse = await dio.fetch(newOptions);
                  return handler.resolve(retryResponse);
                }
              } catch (refreshError) {
                TalkerLoggerUtil.talker.error('Interceptor Refresh Failed', refreshError);
                // Если рефреш не удался - чистим все, чтобы выкинуло на логин
                await authDao.user.setValue('null');
                const storage = FlutterSecureStorage();
                await storage.delete(key: 'refresh_token');
                // Возвращаем ошибку дальше, чтобы сработал логаут в BLoC
                return handler.next(e); 
              }
            }
            return handler.next(e);
          },
        ),
      );
    }

    dio.interceptors.add(
      TalkerDioLogger(
        talker: TalkerLoggerUtil.talker,
        settings: const TalkerDioLoggerSettings(
            printResponseHeaders: false,
            printRequestHeaders: true,
            printResponseData: true,
            printRequestData: true),
      ),
    );

    dio.interceptors.add(dioInterceptor);
  }
}
