import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:coment_app/src/core/rest_client/rest_client.dart';
import 'package:coment_app/src/core/utils/talker_logger_util.dart';
import 'package:coment_app/src/feature/auth/data/auth_repository.dart';
import 'package:coment_app/src/feature/auth/database/auth_dao.dart';
import 'package:coment_app/src/feature/main/model/feedback_dto.dart';
import 'package:coment_app/src/feature/main/model/product_dto.dart';
import 'package:coment_app/src/feature/profile/models/response/verification_response.dart';
import 'package:coment_app/src/feature/profile/models/response/verification_status.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:coment_app/src/core/rest_client/models/basic_response.dart';
import 'package:coment_app/src/feature/auth/models/user_dto.dart';
import 'package:coment_app/src/feature/profile/data/profile_remote_ds.dart';

abstract interface class IProfileRepository {
  Future<UserDTO> profileData();

  Future<BasicResponse> deleteAccount({required String password});

  Future<BasicResponse> logout();

  Future<BasicResponse> writeTechSupport({
    required String subject,
    required String message,
    required String category,
    required String contactEmail,
  });

  Future<List<FeedbackDTO>> myFeedbacks();

  Future<BasicResponse> editAccount({
    required String password,
    required String name,
    required String email,
    String? birthDate,
    required String phone,
    required int cityId,
    required int languageId,
    XFile? avatar,
  });

  Future<List<String>> uploadDocuments(
    List<File> files,
    // {required int companyId}
  );

  Future<List<ProductDTO>> getMyCompanies();
  Future<VerificationResponse> createVerificationRequest({
    required int companyId,
    required List<String> documentUrls,
  });

  Future<VerificationStatus> getVerificationStatus();
  Future<UserDTO> updateSettings({bool? showRealName});
}

class ProfileRepositoryImpl implements IProfileRepository {
  const ProfileRepositoryImpl({
    required IProfileRemoteDS remoteDS,
    required IAuthDao authDao, // ✅ Добавлена зависимость
    required IAuthRepository authRepository,
  })  : _remoteDS = remoteDS,
        _authDao = authDao,
        _authRepository = authRepository;

  final IProfileRemoteDS _remoteDS;
  final IAuthDao _authDao;
  final IAuthRepository _authRepository;
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
  Future<BasicResponse> deleteAccount({required String password}) async {
    try {
      final result = await _remoteDS.deleteAccount(password: password);
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
    String? birthDate,
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
        avatar: avatar,
        birthDate: birthDate,
      );
    } on CustomBackendException catch (e) {
      if (e.statusCode == 401) {
        try {
          await _authRepository.refreshAccessToken();
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
          await _authRepository.clearUser();
          rethrow;
        }
      }
      rethrow;
    }
  }

  @override
  Future<BasicResponse> writeTechSupport({
    required String subject,
    required String message,
    required String category,
    required String contactEmail,
  }) async {
    try {
      return await _remoteDS.writeTechSupport(
        subject: subject,
        message: message,
        category: category,
        contactEmail: contactEmail,
      );
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

  @override
  Future<List<String>> uploadDocuments(
    List<File> files,
    // {required int companyId}
  ) async {
    try {
      return await _remoteDS.uploadDocuments(
        files,
        // companyId,
      );
    } on CustomBackendException catch (e) {
      if (e.statusCode == 401) {
        try {
          await _authRepository.refreshAccessToken();
          return await _remoteDS.uploadDocuments(
            files,
            // companyId,
          );
        } catch (refreshError) {
          rethrow;
        }
      }
      rethrow;
    }
  }

  @override
  Future<List<ProductDTO>> getMyCompanies() async {
    try {
      return await _remoteDS.getMyCompanies();
    } on CustomBackendException catch (e) {
      if (e.statusCode == 401) {
        try {
          await _authRepository.refreshAccessToken();
          return await _remoteDS.getMyCompanies();
        } catch (refreshError) {
          await _authRepository.clearUser();
          rethrow;
        }
      }
      rethrow;
    }
  }

  @override
  Future<VerificationResponse> createVerificationRequest({
    required int companyId,
    required List<String> documentUrls,
  }) async {
    try {
      return await _remoteDS.createVerificationRequest(
        companyId: companyId,
        documentUrls: documentUrls,
      );
    } on CustomBackendException catch (e) {
      if (e.statusCode == 401) {
        try {
          await _authRepository.refreshAccessToken();
          return await _remoteDS.createVerificationRequest(
            companyId: companyId,
            documentUrls: documentUrls,
          );
        } catch (refreshError) {
          await _authRepository.clearUser();
          rethrow;
        }
      }
      rethrow;
    }
  }

  @override
  Future<VerificationStatus> getVerificationStatus() async {
    final response = await _remoteDS.getVerificationStatus();
    return response;
  }



@override
Future<UserDTO> updateSettings({bool? showRealName}) async {
  try {
    final updatedUser = await _remoteDS.updateSettings(showRealName: showRealName);
    
    // ✅ ИСПРАВЛЕНИЕ: Сериализуем объект UserDTO в JSON-строку
    final userJsonString = jsonEncode(updatedUser.toJson());
    await _authDao.user.setValue(userJsonString);
    
    return updatedUser;
  } on CustomBackendException catch (e) {
    if (e.statusCode == 401) {
      try {
        await _authRepository.refreshAccessToken();
        final updatedUser = await _remoteDS.updateSettings(showRealName: showRealName);
        
        // Повторяем здесь
        await _authDao.user.setValue(jsonEncode(updatedUser.toJson()));
        
        return updatedUser;
      } catch (refreshError) {
        await _authRepository.clearUser();
        rethrow;
      }
    }
    rethrow;
  }
}
}
