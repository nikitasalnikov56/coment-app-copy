import 'dart:developer';
import 'dart:io';
import 'package:coment_app/src/feature/main/model/feedback_dto.dart';
import 'package:coment_app/src/feature/main/model/product_dto.dart';
import 'package:coment_app/src/feature/profile/models/response/verification_response.dart';
import 'package:coment_app/src/feature/profile/models/response/verification_status.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:coment_app/src/core/rest_client/models/basic_response.dart';
import 'package:coment_app/src/core/rest_client/rest_client.dart';
import 'package:coment_app/src/core/utils/talker_logger_util.dart';
import 'package:coment_app/src/feature/auth/models/user_dto.dart';

abstract interface class IProfileRemoteDS {
  Future<UserDTO> profileData();

  Future<BasicResponse> deleteAccount({required String password});

  // 👇 Изменили сигнатуру: теперь принимаем refreshToken
  Future<BasicResponse> logOut({required String refreshToken});

  Future<BasicResponse> writeTechSupport({
    required String subject,
    required String message,
    required String category,
    required String contactEmail,
  });

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

  Future<List<FeedbackDTO>> myFeedbacks();

  Future<List<String>> uploadDocuments(
    List<File> files,
    // int companyId,
  );

  Future<List<String>> getMyDocuments();

  Future<void> deleteDocument(String url);

  Future<List<ProductDTO>> getMyCompanies();
  Future<VerificationResponse> createVerificationRequest({
    required int companyId,
    required List<String> documentUrls,
  });

  Future<VerificationStatus> getVerificationStatus();
  Future<UserDTO> updateSettings({bool? showRealName});
}

class ProfileRemoteDSImpl implements IProfileRemoteDS {
  const ProfileRemoteDSImpl({
    required this.restClient,
  });
  final IRestClient restClient;

  @override
  Future<UserDTO> profileData() async {
    try {
      final Map<String, dynamic> response = await restClient.get(
        'auth/profile',
        queryParams: {},
      );

      return UserDTO.fromJson(response);
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#getProfile - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<BasicResponse> deleteAccount({required String password}) async {
    try {
      final body = {'password': password};
      final Map<String, dynamic> response = await restClient.delete(
        'auth/delete',
        body: body,
      );

      return BasicResponse.fromJson(response);
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#deleteAccount - $e', e, st);
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
    String? birthDate,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (email.isNotEmpty) data['email'] = email;
      if (phone.isNotEmpty) data['phone'] = phone;
      if (name.isNotEmpty) data['name'] = name;
      if (cityId > 0) data['city_id'] = cityId.toString();
      if (password.isNotEmpty) data['password'] = password;
      if (languageId > 0) data['language_id'] = languageId.toString();
      if (birthDate != null && birthDate.isNotEmpty) {
        data['birthDate'] = birthDate;
      }

      final FormData formData = FormData.fromMap(data);
      if (avatar != null) {
        formData.files.add(
          MapEntry(
            'avatar',
            await MultipartFile.fromFile(
              avatar.path,
              filename: avatar.name.isNotEmpty ? avatar.name : 'upload.jpg',
            ),
          ),
        );
      }

      final Map<String, dynamic> response = await restClient.post(
        'auth/edit',
        body: formData,
      );
      log('$avatar', name: 'remote avatar');
      log('Response from edit: $response', name: 'ProfileRemoteDS');

      return BasicResponse.fromJson(response);
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#editAccount - $e', e, st);
      rethrow;
    }
  }

  @override
  // 👇 Реализация безопасного выхода
  Future<BasicResponse> logOut({required String refreshToken}) async {
    try {
      // Передаем refresh_token в теле запроса, чтобы бэкенд его удалил
      final Map<String, dynamic> response = await restClient.post(
        'auth/logout', // Убрал слеш в начале, обычно restClient сам добавляет
        body: {'refresh_token': refreshToken},
      );

      return BasicResponse.fromJson(response);
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#logout - $e', e, st);
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
      final body = {
        'subject': subject,
        'message': message,
        'category': category,
        'contactEmail': contactEmail,
        'priority': 'medium',
      };
      final Map<String, dynamic> response = await restClient.post(
        '/support/create',
        body: body,
      );

      return BasicResponse.fromJson(response);
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#writeTechSupport - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<List<FeedbackDTO>> myFeedbacks() async {
    try {
      final Map<String, dynamic> response = await restClient.get(
        '/feedback',
        queryParams: {},
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
      TalkerLoggerUtil.talker.error('#getMyFeedbacks - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<List<String>> uploadDocuments(
    List<File> files,
    // int companyId,
  ) async {
    final formData = FormData();
    for (final file in files) {
      formData.files.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ),
      );
    }

    final response = await restClient.post(
      'uploads/documents',
      body: formData,
      // headers: {'Content-Type': 'multipart/form-data'},
    );
    final urls = response['urls'] as List?;
    return urls?.map((e) => e as String).toList() ?? [];
  }

  @override
  Future<List<String>> getMyDocuments() async {
    final response = await restClient.get('uploads/my-documents');
    final urls = response['urls'] as List?;
    return urls?.map((e) => e as String).toList() ?? [];
  }

  @override
  Future<void> deleteDocument(String url) async {
    await restClient.delete('uploads/document', body: {'url': url});
  }

  @override
  Future<VerificationStatus> getVerificationStatus() async {
    try {
      final Map<String, dynamic> response = await restClient.get(
        '/verification/status',
        queryParams: {},
      );
      return VerificationStatus.fromJson(response);
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#getVerificationStatus - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<List<ProductDTO>> getMyCompanies() async {
    try {
      final response = await restClient.get('/verification/companies/me');
      final list = response['data'] as List?; // ← Берём массив из поля 'data'
      if (list == null) {
        return [];
      }
      return list
          .map((e) => ProductDTO.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#getMyCompanies - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<VerificationResponse> createVerificationRequest({
    required int companyId,
    required List<String> documentUrls,
  }) async {
    try {
      final body = {
        'companyId': companyId,
        'documentUrls': documentUrls,
      };
      final response =
          await restClient.post('/verification/requests', body: body);
      return VerificationResponse.fromJson(response);
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#createVerificationRequest - $e', e, st);
      rethrow;
    }
  }


@override
Future<UserDTO> updateSettings({bool? showRealName}) async {
  try {
    final Map<String, dynamic> body = {
      if (showRealName != null) 'showRealName': showRealName,
    };

    final response = await restClient.post(
      'auth/edit',
      body: body,
    );

    // Теперь мы видим, что RestClient уже вернул содержимое "data"
    // Поэтому просто парсим пришедшую мапу
    return UserDTO.fromJson(response); 
    
  } catch (e, st) {
    TalkerLoggerUtil.talker.error('#updateSettings error', e, st);
    rethrow;
  }
}
}
