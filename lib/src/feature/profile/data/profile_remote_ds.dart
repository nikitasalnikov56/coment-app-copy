import 'dart:developer';

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

  Future<BasicResponse> deleteAccount();

  Future<BasicResponse> logOut();

  Future<BasicResponse> writeTechSupport({required String text});

  Future<BasicResponse> editAccount({
    required String password,
    required String name,
    required String email,
    required String phone,
    required int cityId,
    required int languageId,
    XFile? avatar,
  });

  Future<List<FeedbackDTO>> myFeedbacks();
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
        'auth/show/',
        queryParams: {},
      );

      return UserDTO.fromJson(response);
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#getProfile - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<BasicResponse> deleteAccount() async {
    try {
      final Map<String, dynamic> response = await restClient.delete(
        'auth/delete',
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
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (email.isNotEmpty) data['email'] = email;
      if (phone.isNotEmpty) data['phone'] = phone;
      if (name.isNotEmpty) data['name'] = name;
      if (cityId > 0) data['city_id'] = cityId;
      if (password.isNotEmpty) data['password'] = password;
      if (languageId > 0) data['language_id'] = languageId;

      final FormData formData = FormData.fromMap(data);
      if (avatar != null) {
        formData.files.add(
          MapEntry('avatar', await MultipartFile.fromFile(avatar.path)),
        );
      }

      final Map<String, dynamic> response = await restClient.post(
        'auth/edit',
        body: formData,
      );
      log('$avatar', name: 'remote avatar');

      return BasicResponse.fromJson(response);
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#editAccount - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<BasicResponse> logOut() async {
    try {
      final Map<String, dynamic> response = await restClient.post('/auth/logout', body: null);

      return BasicResponse.fromJson(response);
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#logout - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<BasicResponse> writeTechSupport({required String text}) async {
    try {
      final Map<String, dynamic> response = await restClient.post('/support/create', body: {'text': text});

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
}
