// import 'dart:developer';
// import 'package:coment_app/src/core/rest_client/rest_client.dart';
// import 'package:dio/dio.dart';
// import 'package:coment_app/src/feature/main/model/feedback_dto.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:coment_app/src/core/rest_client/models/basic_response.dart';
// import 'package:coment_app/src/feature/auth/models/user_dto.dart';
// import 'package:coment_app/src/feature/profile/data/profile_remote_ds.dart';

// abstract interface class IProfileRepository {
//   Future<UserDTO> profileData();

//   Future<BasicResponse> deleteAccount();

//   Future<BasicResponse> logout();

//   Future<BasicResponse> writeTechSupport({required String text});

//   Future<List<FeedbackDTO>> myFeedbacks();

//   Future<BasicResponse> editAccount({
//     required String password,
//     required String name,
//     required String email,
//     required String phone,
//     required int cityId,
//     required int languageId,
//     XFile? avatar,
//   });

//   Future<void> updateProfile({
//     String? name,
//     String? email,
//     String? phone,
//     String? password,
//     String? birthDate,
//     int? cityId,
//     int? languageId,
//   });

//   Future<String> uploadAvatar(XFile avatar);
// }

// class ProfileRepositoryImpl implements IProfileRepository {
//   const ProfileRepositoryImpl({
//     required IProfileRemoteDS remoteDS,
//   }) : _remoteDS = remoteDS;
//   final IProfileRemoteDS _remoteDS;

//   @override
//   Future<UserDTO> profileData() async {
//     try {
//       return await _remoteDS.profileData();
//     } on CustomBackendException catch (e) {
//      if (e.statusCode == 401) {
//       try {
//         // await _authRepository.refreshAccessToken();
//         return await _remoteDS.profileData(); // повторить
//       } catch (refreshError) {
//         // await _authRepository.clearUser();
//         rethrow;
//       }
//     }
//     rethrow;
//     }
//   }

//   //  @override
//   // Future<BasicResponse> logOut() async => _client.execute(
//   //     route:  AuthApi.logout(), responseType: BasicResponse());

//   @override
//   Future<BasicResponse> deleteAccount() async {
//     try {
//       return await _remoteDS.deleteAccount();
//     } catch (e) {
//       rethrow;
//     }
//   }

//   @override
//   Future<BasicResponse> editAccount({
//     required String password,
//     required String name,
//     required String email,
//     required String phone,
//     required int cityId,
//     required int languageId,
//     XFile? avatar,
//   }) async {
//     try {
//       log('$avatar', name: 'repository avatar');
//       return await _remoteDS.editAccount(
//           password: password,
//           name: name,
//           email: email,
//           phone: phone,
//           cityId: cityId,
//           languageId: languageId,
//           avatar: avatar);
//     } on CustomBackendException catch (e) {
//       if (e.statusCode == 401) {
//       try {
//         // await _authRepository.refreshAccessToken();
//         return await _remoteDS.editAccount(
//           password: password,
//           name: name,
//           email: email,
//           phone: phone,
//           cityId: cityId,
//           languageId: languageId,
//           avatar: avatar,
//         );
//       } catch (refreshError) {
//         // await _authRepository.clearUser();
//         rethrow;
//       }
//     }
//     rethrow;
//     }
//   }

//   ///NEW
//   @override
//   Future<void> updateProfile({
//     String? name,
//     String? email,
//     String? phone,
//     String? password,
//     String? birthDate,
//     int? cityId,
//     int? languageId,
//   }) async {
//     final body = <String, dynamic>{};
//     if (name != null) body['name'] = name;
//     if (email != null) body['email'] = email;
//     if (phone != null) body['phone'] = phone;
//     if (password != null) body['password'] = password;
//     if (birthDate != null) body['birthDate'] = birthDate;
//     if (cityId != null) body['cityId'] = cityId;
//     if (languageId != null) body['languageId'] = languageId;

//     await _remoteDS.updateProfile(body);
//   }

//   @override
//   Future<String> uploadAvatar(XFile avatar) async {
//     final formData = FormData();
//     formData.files.add(MapEntry(
//       'avatar',
//       await MultipartFile.fromFile(avatar.path, filename: avatar.name),
//     ));
//     final response = await _remoteDS.uploadAvatar(formData);
//     return response['avatarUrl'] as String;
//   }

//   ///

//   @override
//   Future<BasicResponse> writeTechSupport({required String text}) async {
//     try {
//       return await _remoteDS.writeTechSupport(text: text);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   @override
//   Future<BasicResponse> logout() async {
//     try {
//       return await _remoteDS.logOut();
//     } catch (e) {
//       rethrow;
//     }
//   }

//   @override
//   Future<List<FeedbackDTO>> myFeedbacks() async {
//     try {
//       return await _remoteDS.myFeedbacks();
//     } on CustomBackendException catch (e) {
//       if (e.statusCode == 401) {
//       try {
//         // await _authRepository.refreshAccessToken();
//         return await _remoteDS.myFeedbacks();
//       } catch (refreshError) {
//         // await _authRepository.clearUser();
//         rethrow;
//       }
//     }
//     rethrow;
//     }
//   }
// }

import 'dart:developer';
import 'package:coment_app/src/core/rest_client/rest_client.dart';
import 'package:coment_app/src/core/utils/talker_logger_util.dart';
import 'package:coment_app/src/feature/auth/database/auth_dao.dart';
import 'package:dio/dio.dart';
import 'package:coment_app/src/feature/main/model/feedback_dto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:coment_app/src/core/rest_client/models/basic_response.dart';
import 'package:coment_app/src/feature/auth/models/user_dto.dart';
import 'package:coment_app/src/feature/profile/data/profile_remote_ds.dart';

abstract interface class IProfileRepository {
  Future<UserDTO> profileData();

  Future<BasicResponse> deleteAccount();

  Future<BasicResponse> logout();

  Future<BasicResponse> writeTechSupport({required String text});

  Future<List<FeedbackDTO>> myFeedbacks();

  Future<BasicResponse> editAccount({
    required String password,
    required String name,
    required String email,
    required String phone,
    required int cityId,
    required int languageId,
    XFile? avatar,
  });

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? password,
    String? birthDate,
    int? cityId,
    int? languageId,
  });

  Future<String> uploadAvatar(XFile avatar);
}

class ProfileRepositoryImpl implements IProfileRepository {
  const ProfileRepositoryImpl({
    required IProfileRemoteDS remoteDS,
    required IAuthDao authDao, // ✅ Добавлена зависимость
  })  : _remoteDS = remoteDS,
        _authDao = authDao;

  final IProfileRemoteDS _remoteDS;
  final IAuthDao _authDao;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  Future<UserDTO> profileData() async {
    try {
      return await _remoteDS.profileData();
    } on CustomBackendException catch (e) {
      if (e.statusCode == 401) {
        try {
          return await _remoteDS.profileData();
        } catch (refreshError) {
          rethrow;
        }
      }
      rethrow;
    }
  }

  @override
  Future<BasicResponse> deleteAccount() async {
    try {
      final result = await _remoteDS.deleteAccount();
      // ✅ При удалении аккаунта тоже чистим локальные данные
      await _authDao.user.remove();
      await _secureStorage.delete(key: 'refresh_token');
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BasicResponse> editAccount({
    required String password,
    required String name,
    required String email,
    required String phone,
    required int cityId,
    required int languageId,
    XFile? avatar,
  }) async {
    try {
      log('$avatar', name: 'repository avatar');
      return await _remoteDS.editAccount(
          password: password,
          name: name,
          email: email,
          phone: phone,
          cityId: cityId,
          languageId: languageId,
          avatar: avatar);
    } on CustomBackendException catch (e) {
      if (e.statusCode == 401) {
        try {
          return await _remoteDS.editAccount(
            password: password,
            name: name,
            email: email,
            phone: phone,
            cityId: cityId,
            languageId: languageId,
            avatar: avatar,
          );
        } catch (refreshError) {
          rethrow;
        }
      }
      rethrow;
    }
  }

  @override
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? password,
    String? birthDate,
    int? cityId,
    int? languageId,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (phone != null) body['phone'] = phone;
    if (password != null) body['password'] = password;
    if (birthDate != null) body['birthDate'] = birthDate;
    if (cityId != null) body['cityId'] = cityId;
    if (languageId != null) body['languageId'] = languageId;

    await _remoteDS.updateProfile(body);
  }

  @override
  Future<String> uploadAvatar(XFile avatar) async {
    final formData = FormData();
    formData.files.add(MapEntry(
      'avatar',
      await MultipartFile.fromFile(avatar.path, filename: avatar.name),
    ));
    final response = await _remoteDS.uploadAvatar(formData);
    return response['avatarUrl'] as String;
  }

  @override
  Future<BasicResponse> writeTechSupport({required String text}) async {
    try {
      return await _remoteDS.writeTechSupport(text: text);
    } catch (e) {
      rethrow;
    }
  }

  // 👇 ИСПРАВЛЕННЫЙ И БЕЗОПАСНЫЙ LOGOUT
  @override
  Future<BasicResponse> logout() async {
    try {
      // 1. Пытаемся получить refresh токен
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      
      // 2. Если токен есть - шлем запрос на сервер
      if (refreshToken != null) {
        await _remoteDS.logOut(refreshToken: refreshToken);
      }
      
      return const BasicResponse(ok: true);
    } catch (e, st) {
      // Если ошибка сети - логируем, но не прерываем процесс выхода
      TalkerLoggerUtil.talker.error('Logout remote failed', e, st);
      return const BasicResponse(ok: true); 
    } finally {
      // 3. ГАРАНТИРОВАННАЯ ОЧИСТКА ДАННЫХ
      // Выполняется всегда, даже если сервер вернул ошибку
      await _authDao.user.remove();
      await _secureStorage.delete(key: 'refresh_token');
    }
  }

  @override
  Future<List<FeedbackDTO>> myFeedbacks() async {
    try {
      return await _remoteDS.myFeedbacks();
    } on CustomBackendException catch (e) {
      if (e.statusCode == 401) {
        try {
          return await _remoteDS.myFeedbacks();
        } catch (refreshError) {
          rethrow;
        }
      }
      rethrow;
    }
  }
}