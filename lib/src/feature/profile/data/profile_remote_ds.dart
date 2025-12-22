import 'dart:developer';
import 'dart:io';

import 'package:coment_app/src/feature/main/model/feedback_dto.dart';
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

  Future<List<String>> uploadDocuments(List<File> files);
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
      if (birthDate != null && birthDate.isNotEmpty)
        data['birthDate'] = birthDate;

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
  Future<List<String>> uploadDocuments(List<File> files) async {
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
}
