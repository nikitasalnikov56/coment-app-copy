// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';

// import 'package:coment_app/src/feature/auth/data/auth_remote_ds.dart';
// import 'package:coment_app/src/feature/auth/database/auth_dao.dart';
// import 'package:coment_app/src/feature/auth/models/user_dto.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// abstract interface class IAuthRepository {
//   bool get isAuthenticated;

//   UserDTO? get user;

//   int? get cityId;

//   Future setCityId({
//     required int cityId,
//   });

//   Future<void> clearUser();

//   UserDTO? cacheUser();

//   Future<UserDTO> login({
//     required String email,
//     required String password,
//     String? deviceType,
//   });

//   Future<UserDTO> register({
//     required String name,
//     required String email,
//     required String password,
//     required String phone,
//     String? deviceType,
//     required String birthDate,
//     String? recaptchaToken,
//   });

//   Future<String> forgotPassword({
//     required String email,
//   });

//   Future<String> sendSms({
//     required String code,
//     required String token,
//   });

//   Future newPassword({
//     required String password,
//     required String passwordConfirmation,
//     required String token,
//   });

//   // TODO-------------------------

//   Future<List<Map<String, dynamic>>> getForceUpdateVersion();

//   Future sendDeviceToken();
//   Future<void> refreshAccessToken();
// }

// class AuthRepositoryImpl implements IAuthRepository {
//   const AuthRepositoryImpl({
//     required IAuthRemoteDS remoteDS,
//     required IAuthDao authDao,
//   })  : _remoteDS = remoteDS,
//         _authDao = authDao;
//   final IAuthRemoteDS _remoteDS;
//   final IAuthDao _authDao;
//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

//   @override
//   bool get isAuthenticated => _authDao.user.value != null;

//   @override
//   int? get cityId {
//     try {
//       final cityId = _authDao.cityId.value;
//       log('${_authDao.cityId.value}', name: 'Auth repository - cityId');
//       if (cityId != null) {
//         return cityId;
//       } else {
//         return null;
//       }
//     } catch (e) {
//       return null;
//     }
//   }

//   @override
//   Future<void> setCityId({
//     required int cityId,
//   }) async {
//     try {
//       await _authDao.cityId.setValue(cityId);
//       log(name: 'City id', _authDao.cityId.value.toString());
//     } catch (e) {
//       rethrow;
//     }
//   }

//   @override
//   UserDTO? cacheUser() {
//     try {
//       if (_authDao.user.value != null) {
//         final UserDTO user = UserDTO.fromJson(
//           jsonDecode(_authDao.user.value!) as Map<String, dynamic>,
//         );
//         return user;
//       }
//     } on Exception catch (e) {
//       log(e.toString(), name: 'getUserFromCache()');
//     }
//     return null;
//   }

//   @override
//   Future<void> clearUser() async {
//     try {
//       await _authDao.user.remove();
//       await _secureStorage.delete(key: 'refresh_token');
//       await _authDao.deviceToken.remove();
//       await _authDao.cityId.remove();
//     } catch (e) {
//       rethrow;
//     }
//   }

//   @override
//   Future<List<Map<String, dynamic>>> getForceUpdateVersion() async {
//     return [
//       {
//         'key': 'force_update_version',
//         'value': '1.0.0',
//       },
//       {
//         'key': 'store_review_version',
//         'value': '1.0.0',
//       },
//     ];
//   }

//   @override
//   Future sendDeviceToken() async {
//     final String? dv = _authDao.deviceToken.value;
//     try {
//       final deviceToken = dv ?? '';

//       await _remoteDS.sendDeviceToken(
//           deviceToken: deviceToken,
//           deviceType: Platform.isAndroid ? 'Android' : 'IOS');
//     } catch (e) {
//       rethrow;
//     }
//   }

//   @override
//   Future<UserDTO> login({
//     required String email,
//     required String password,
//     String? deviceType,
//   }) async {
//     final String? deviceToken = _authDao.deviceToken.value;
//     log('Attempting login with email: $email, deviceToken: $deviceToken',
//         name: 'auth repo');
//     log('${_authDao.deviceToken.value}', name: 'auth repo device token');
//     try {
//       final user = await _remoteDS.login(
//         email: email,
//         password: password,
//         deviceToken: deviceToken,
//         deviceType: deviceType,
//       );
//       await _secureStorage.write(
//           key: 'refresh_token', value: user.refreshToken);
//       log('Login successful, user: $user', name: 'auth repo');
//       await _authDao.user.setValue(jsonEncode(user.toJson()));
//       log('$user', name: 'auth-repo');
//       log('User saved to SharedPreferences: ${await _authDao.user.value}',
//           name: 'auth repo');
//       return user;
//     } catch (e) {
//       log('Login error: $e', name: 'auth repo', error: e);
//       rethrow;
//     }
//   }

//   // @override
//   // Future<void> refreshAccessToken() async {
//   //   final refreshToken = await _secureStorage.read(key: 'refresh_token');
//   //   log('READ refresh_token: $refreshToken', name: 'REFRESH');
//   //   if (refreshToken == null) throw Exception('No refresh token');

//   //   final response = await _remoteDS.refreshToken(refreshToken);

//   //   // final userStr = _authDao.user.value;
//   //   // if (userStr != null) {
//   //   //   final userMap = jsonDecode(userStr) as Map<String, dynamic>;
//   //   //   if (response.containsKey('user')) {
//   //   //     final newUser = response['user'] as Map<String, dynamic>;
//   //   //     userMap['id'] = newUser['id'];
//   //   //     userMap['name'] = newUser['name'];
//   //   //     userMap['email'] = newUser['email'];
//   //   //     userMap['phoneNumber'] = newUser['phoneNumber'];
//   //   //   }
//   //   //   // userMap['access_token'] = response['access_token'];
//   //   //   await _authDao.user.setValue(jsonEncode(userMap));
//   //   // }
//   //   // Создаём НОВЫЙ объект пользователя из ответа
//   //   final newUserJson = response['user'] as Map<String, dynamic>;
//   //   newUserJson['access_token'] = response['access_token'];
//   //   newUserJson['refresh_token'] = refreshToken; // опционально

//   //   // Сохраняем ПОЛНОСТЬЮ нового пользователя
//   //   await _authDao.user.setValue(jsonEncode(newUserJson));
//   // }

// @override
//   Future<void> refreshAccessToken() async {
//     // 1. Читаем текущий токен
//     final refreshToken = await _secureStorage.read(key: 'refresh_token');
//     log('READ refresh_token: $refreshToken', name: 'REFRESH');
    
//     if (refreshToken == null) throw Exception('No refresh token');

//     // 2. Делаем запрос (теперь ответ будет содержать новый refresh_token)
//     final response = await _remoteDS.refreshToken(refreshToken);

//     // 3. ✅ СОХРАНЯЕМ НОВЫЙ REFRESH TOKEN
//     final newRefreshToken = response['refresh_token'] as String?;
//     if (newRefreshToken != null) {
//       await _secureStorage.write(key: 'refresh_token', value: newRefreshToken);
//       log('UPDATED refresh_token: $newRefreshToken', name: 'REFRESH');
//     }

//     // 4. Обновляем access_token в объекте User (в SharedPreferences)
//     final userStr = _authDao.user.value;
//     if (userStr != null) {
//       final userMap = jsonDecode(userStr) as Map<String, dynamic>;
      
//       userMap['access_token'] = response['access_token'];
      
//       // Если бэкенд не возвращает refresh_token внутри user, можно обновить его и тут для консистентности,
//       // но главное - это secureStorage.
//       if (newRefreshToken != null) {
//          userMap['refresh_token'] = newRefreshToken;
//       }

//       await _authDao.user.setValue(jsonEncode(userMap));
//     }
//   }

//   @override
//   UserDTO? get user {
//     try {
//       final userStr = _authDao.user.value;
//       if (userStr != null) {
//         // log(userStr, name: 'user in auth repo');
//         return UserDTO.fromJson(
//           jsonDecode(userStr) as Map<String, dynamic>,
//         );
//       } else {
//         return null;
//       }
//     } catch (e) {
//       return null;
//     }
//   }

//   @override
//   Future<UserDTO> register({
//     required String name,
//     required String email,
//     required String password,
//     required String phone,
//     String? deviceType,
//     required String birthDate,
//     String? recaptchaToken,
//   }) async {
//     final String? dv = _authDao.deviceToken.value;
//     try {
//       final user = await _remoteDS.register(
//         name: name,
//         email: email,
//         password: password,
//         deviceToken: dv,
//         deviceType: deviceType,
//         phone: phone,
//         birthDate: birthDate,
//         recaptchaToken: recaptchaToken,
//       );
//       await _secureStorage.write(
//           key: 'refresh_token', value: user.refreshToken);
//       log('SAVED refresh_token: ${user.refreshToken}', name: 'AUTH');
//       await _authDao.user.setValue(jsonEncode(user.toJson()));
//       print(
//           'Когда уже сука закончу я с этим ебучим рефреш токеном: ${user.refreshToken}');
//       return user;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   @override
//   Future<String> forgotPassword({required String email}) async {
//     try {
//       return await _remoteDS.forgotPassword(email: email);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   @override
//   Future<String> sendSms({required String code, required String token}) async {
//     try {
//       return await _remoteDS.sendSms(code: code, token: token);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   @override
//   Future newPassword(
//       {required String password,
//       required String passwordConfirmation,
//       required String token}) async {
//     try {
//       return await _remoteDS.newPassword(
//           password: password,
//           passwordConfirmation: passwordConfirmation,
//           token: token);
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:coment_app/src/feature/auth/data/auth_remote_ds.dart';
import 'package:coment_app/src/feature/auth/database/auth_dao.dart';
import 'package:coment_app/src/feature/auth/models/user_dto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class IAuthRepository {
  bool get isAuthenticated;

  UserDTO? get user;

  int? get cityId;

  Future setCityId({
    required int cityId,
  });

  Future<void> clearUser();

  UserDTO? cacheUser();

  Future<UserDTO> login({
    required String email,
    required String password,
    String? deviceType,
    String? recaptchaToken,
  });

  Future<UserDTO> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? deviceType,
    required String birthDate,
    String? recaptchaToken,
  });

  Future<String> forgotPassword({
    required String email,
  });

  Future<String> sendSms({
    required String code,
    required String token,
  });

  Future newPassword({
    required String password,
    required String passwordConfirmation,
    required String token,
  });

  Future<List<Map<String, dynamic>>> getForceUpdateVersion();

  Future sendDeviceToken();
  
  Future<void> refreshAccessToken();
}

class AuthRepositoryImpl implements IAuthRepository {
  const AuthRepositoryImpl({
    required IAuthRemoteDS remoteDS,
    required IAuthDao authDao,
  })  : _remoteDS = remoteDS,
        _authDao = authDao;
  final IAuthRemoteDS _remoteDS;
  final IAuthDao _authDao;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  bool get isAuthenticated => _authDao.user.value != null;

  @override
  int? get cityId {
    try {
      final cityId = _authDao.cityId.value;
      log('${_authDao.cityId.value}', name: 'Auth repository - cityId');
      if (cityId != null) {
        return cityId;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> setCityId({
    required int cityId,
  }) async {
    try {
      await _authDao.cityId.setValue(cityId);
      log(name: 'City id', _authDao.cityId.value.toString());
    } catch (e) {
      rethrow;
    }
  }

  @override
  UserDTO? cacheUser() {
    try {
      if (_authDao.user.value != null) {
        final UserDTO user = UserDTO.fromJson(
          jsonDecode(_authDao.user.value!) as Map<String, dynamic>,
        );
        return user;
      }
    } on Exception catch (e) {
      log(e.toString(), name: 'getUserFromCache()');
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    try {
      await _authDao.user.remove();
      await _secureStorage.delete(key: 'refresh_token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getForceUpdateVersion() async {
    return [
      {
        'key': 'force_update_version',
        'value': '1.0.0',
      },
      {
        'key': 'store_review_version',
        'value': '1.0.0',
      },
    ];
  }

  @override
  Future sendDeviceToken() async {
    final String? dv = _authDao.deviceToken.value;
    try {
      final deviceToken = dv ?? '';

      await _remoteDS.sendDeviceToken(
          deviceToken: deviceToken,
          deviceType: Platform.isAndroid ? 'Android' : 'IOS');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserDTO> login({
    required String email,
    required String password,
    String? deviceType,
    String? recaptchaToken,
  }) async {
    final String? deviceToken = _authDao.deviceToken.value;
    log('Attempting login with email: $email, deviceToken: $deviceToken',
        name: 'auth repo');
    try {
      final user = await _remoteDS.login(
        email: email,
        password: password,
        deviceToken: deviceToken,
        deviceType: deviceType,
        recaptchaToken: recaptchaToken,
      );
      // Сохраняем refresh в secure storage
      await _secureStorage.write(key: 'refresh_token', value: user.refreshToken);
      
      // Сохраняем UserDTO в SharedPrefs
      await _authDao.user.setValue(jsonEncode(user.toJson()));
      
      log('Login successful, user: $user', name: 'auth repo');
      return user;
    } catch (e) {
      log('Login error: $e', name: 'auth repo', error: e);
      rethrow;
    }
  }

  @override
  Future<void> refreshAccessToken() async {
    // 1. Читаем текущий токен
    final refreshToken = await _secureStorage.read(key: 'refresh_token');
    log('READ refresh_token: $refreshToken', name: 'REFRESH');
    
    if (refreshToken == null) throw Exception('No refresh token');

    // 2. Делаем запрос (теперь ответ содержит новый refresh_token)
    final response = await _remoteDS.refreshToken(refreshToken);

    // 3. ✅ СОХРАНЯЕМ НОВЫЙ REFRESH TOKEN В SECURE STORAGE
    final newRefreshToken = response['refresh_token'] as String?;
    if (newRefreshToken != null) {
      await _secureStorage.write(key: 'refresh_token', value: newRefreshToken);
      log('UPDATED refresh_token: $newRefreshToken', name: 'REFRESH');
    }

    // 4. Обновляем access_token (и refresh) в объекте User (SharedPreferences)
    final userStr = _authDao.user.value;
    if (userStr != null) {
      final userMap = jsonDecode(userStr) as Map<String, dynamic>;
      
      userMap['access_token'] = response['access_token'];
      
      if (newRefreshToken != null) {
         userMap['refresh_token'] = newRefreshToken;
      }

      await _authDao.user.setValue(jsonEncode(userMap));
    }
  }

  @override
  UserDTO? get user {
    try {
      final userStr = _authDao.user.value;
      if (userStr != null) {
        return UserDTO.fromJson(
          jsonDecode(userStr) as Map<String, dynamic>,
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserDTO> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? deviceType,
    required String birthDate,
    String? recaptchaToken,
  }) async {
    final String? dv = _authDao.deviceToken.value;
    try {
      final user = await _remoteDS.register(
        name: name,
        email: email,
        password: password,
        deviceToken: dv,
        deviceType: deviceType,
        phone: phone,
        birthDate: birthDate,
        recaptchaToken: recaptchaToken,
      );
      
      await _secureStorage.write(key: 'refresh_token', value: user.refreshToken);
      log('SAVED refresh_token: ${user.refreshToken}', name: 'AUTH');
      
      await _authDao.user.setValue(jsonEncode(user.toJson()));
      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> forgotPassword({required String email}) async {
    try {
      return await _remoteDS.forgotPassword(email: email);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> sendSms({required String code, required String token}) async {
    try {
      return await _remoteDS.sendSms(code: code, token: token);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future newPassword(
      {required String password,
      required String passwordConfirmation,
      required String token}) async {
    try {
      return await _remoteDS.newPassword(
          password: password,
          passwordConfirmation: passwordConfirmation,
          token: token);
    } catch (e) {
      rethrow;
    }
  }
}