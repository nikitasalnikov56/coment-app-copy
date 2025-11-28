import 'package:coment_app/src/feature/app/logic/notification_service.dart';
import 'package:coment_app/src/feature/auth/database/auth_dao.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gcaptcha_v3/recaptca_config.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:coment_app/src/feature/auth/data/auth_repository.dart';
import 'package:coment_app/src/feature/auth/models/user_dto.dart';

part 'register_cubit.freezed.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({
    required IAuthRepository repository,
    required IAuthDao authDao,
  })  : _repository = repository,
        _authDao = authDao,
        super(const RegisterState.initial());
  final IAuthRepository _repository;
  final IAuthDao _authDao;
// Future<String?> _getRecaptchaToken() async {
//     try {
//       final token = await RecaptchaHandler.executeV3(action: 'register');
//       return token;
//     } catch (e) {
//       emit(RegisterState.error(message: 'Ошибка reCAPTCHA: $e'));
//       return null;
//     }
//   }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? deviceType,
    required String birthDate,
    String? recaptchaToken,
  }) async {
    try {
      emit(const RegisterState.loading());
      // 🔥 ОЧИСТИТЕ КЭШ ПЕРЕД РЕГИСТРАЦИЕЙ
      await _repository.clearUser();

      // ✅ Получаем токен reCAPTCHA
      const recaptchaToken = 'dev_token_for_local';
      // final recaptchaToken = await _getRecaptchaToken();
      // if (recaptchaToken == null) return;

      // Очищаем номер телефона
      final String cleanedPhone = '+${phone.replaceAll(RegExp(r'[^0-9]'), '')}';

      final data = await _repository.register(
        email: email,
        name: name,
        password: password,
        deviceType: deviceType,
        phone: cleanedPhone,
        // phone: phone,
        birthDate: birthDate,
        recaptchaToken: recaptchaToken,
      );

      if (isClosed) return;
      if (!kIsWeb) {
        final notificationService = NotificationService();
        await notificationService.getDeviceToken(authDao: _authDao);
        final deviceToken = _authDao.deviceToken.value;
        if (deviceToken != null) {
          await _repository.sendDeviceToken();
        }
      }
      emit(RegisterState.loaded(user: data));
    } catch (e) {
      emit(
        RegisterState.error(
          message: e.toString(),
        ),
      );
    }
  }
}

@freezed
class RegisterState with _$RegisterState {
  const factory RegisterState.initial() = _InitialState;

  const factory RegisterState.loading() = _LoadingState;

  const factory RegisterState.loaded({
    required UserDTO user,
  }) = _LoadedState;

  const factory RegisterState.error({
    required String message,
  }) = _ErrorState;
}
