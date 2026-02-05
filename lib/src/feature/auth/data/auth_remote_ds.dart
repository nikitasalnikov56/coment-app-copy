import 'package:coment_app/src/core/rest_client/rest_client.dart';
import 'package:coment_app/src/core/utils/jwt_parser.dart';
import 'package:coment_app/src/core/utils/talker_logger_util.dart';
import 'package:coment_app/src/feature/auth/models/user_dto.dart';

abstract interface class IAuthRemoteDS {
  Future<UserDTO> login({
    required String email,
    required String password,
    String? deviceToken,
    String? deviceType,
    String? recaptchaToken,
  });

  Future<UserDTO> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? deviceToken,
    String? deviceType,
    required String birthDate,
    String? recaptchaToken,
    required String role,
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

  Future sendDeviceToken({
    required String deviceToken,
    required String deviceType,
  });

  Future<Map<String, dynamic>> refreshToken(String refreshToken);
  UserDTO updateUserFromToken(UserDTO user);
}

class AuthRemoteDSImpl implements IAuthRemoteDS {
  const AuthRemoteDSImpl({
    required this.restClient,
  });
  final IRestClient restClient;

  /// Обновляет данные пользователя из JWT токена
  @override
  UserDTO updateUserFromToken(UserDTO user) {
    if (user.accessToken == null || user.accessToken!.isEmpty) return user;

    final payload = JwtParser.parsePayload(user.accessToken!);
    if (payload == null) return user;

    final userId = payload['sub'] as int?;
    final role = payload['role'] as String?;
    final email = payload['email'] as String?;

    return user.copyWith(
      id: userId ?? user.id,
      role: role ?? user.role,
      email: email ?? user.email,
    );
  }

  @override
  Future<UserDTO> login({
    required String email,
    required String password,
    String? deviceToken,
    String? deviceType,
    String? recaptchaToken,
  }) async {
    try {
      final Map<String, dynamic> response = await restClient.post(
        'auth/login',
        body: {
          'email': email,
          'password': password,
          'recaptchaToken': recaptchaToken,
          if (deviceToken != null) 'device_token': deviceToken,
          if (deviceType != null) 'device_type': deviceType,
        },
      );

      final user = UserDTO.fromJson(response);

      return updateUserFromToken(user);
      // UserDTO.fromJson(response);
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#login - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<UserDTO> register({
    required String? name,
    required String? email,
    required String? password,
    required String? phone,
    String? deviceToken,
    String? deviceType,
    required String birthDate,
    String? recaptchaToken,
    required String role,
  }) async {
    try {
      final Map<String, dynamic> response = await restClient.post(
        'auth/register',
        body: {
          'name': name,
          'email': email,
          'password': password,
          'phoneNumber': phone,
          // 'phone': phone,
          if (deviceToken != null) 'device_token': deviceToken,
          if (deviceType != null) 'device_type': deviceType,
          'birthDate': birthDate,
          'recaptchaToken': recaptchaToken,
          'role': role,
        },
      );

      final user = UserDTO.fromJson(response);

      return updateUserFromToken(user);
      // return UserDTO.fromJson(response);
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#register - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<String> forgotPassword({required String email}) async {
    try {
      final Map<String, dynamic> response = await restClient.post(
        '/reset/reset-password',
        body: {'email': email},
      );

      final String? payload = response['token'] as String?;
      if (payload != null && payload != '') {
        return payload;
      } else {
        throw WrongResponseTypeException(
          message:
              '''Unexpected response body type: ${response.runtimeType}\n$response''',
        );
      }
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#forgetPassword - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<String> sendSms({required String code, required String token}) async {
    try {
      final Map<String, dynamic> response = await restClient.post(
        '/reset/verify-reset-code',
        body: {'code': code, 'token': token},
      );

      final String? payload = response['token'] as String?;
      if (payload != null && payload != '') {
        return payload;
      } else {
        throw WrongResponseTypeException(
          message:
              '''Unexpected response body type: ${response.runtimeType}\n$response''',
        );
      }
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#sendSmsCode - $e', e, st);
      rethrow;
    }
  }

  @override
  Future newPassword({
    required String password,
    required String passwordConfirmation,
    required String token,
  }) async {
    try {
      await restClient.post(
        '/reset/change-password',
        body: {
          'password': password,
          'password_confirmation': passwordConfirmation,
          'token': token
        },
      );
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#newPassword - $e', e, st);
      rethrow;
    }
  }

  @override
  Future sendDeviceToken({
    required String deviceToken,
    required String deviceType,
  }) async {
    try {
      await restClient.post(
        // '/auth/update-token',
        '/notifications/register-device',
        body: {
          'device_token': deviceToken,
          'device_type': deviceType,
        },
      );
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#sendDeviceToken - $e', e, st);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await restClient.post('auth/refresh', body: {
        'refresh_token': refreshToken,
      });
      return response; // должно содержать {"access_token": "..."}
    } catch (e, st) {
      TalkerLoggerUtil.talker.error('#refreshToken - $e', e, st);
      rethrow;
    }
  }
}
