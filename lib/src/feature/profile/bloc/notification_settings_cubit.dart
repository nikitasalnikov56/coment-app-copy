import 'package:coment_app/src/feature/auth/data/auth_remote_ds.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:coment_app/src/feature/auth/database/auth_dao.dart';
import 'package:coment_app/src/feature/app/logic/notification_service.dart';

part 'notification_settings_cubit.freezed.dart';

@freezed
class NotificationSettingsState with _$NotificationSettingsState {
  const factory NotificationSettingsState.initial() = _Initial;
  const factory NotificationSettingsState.loading() = _Loading;
  const factory NotificationSettingsState.loaded({required bool isEnabled}) =
      _Loaded;
  const factory NotificationSettingsState.error({required String message}) =
      _Error;
}

class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  NotificationSettingsCubit({
    required IAuthDao authDao,
    required NotificationService notificationService,
    required IAuthRemoteDS authRemoteDS,
  })  : _authDao = authDao,
        _notificationService = notificationService,
        _authRemoteDS = authRemoteDS,
        super(const NotificationSettingsState.initial());

  final IAuthDao _authDao;
  final NotificationService _notificationService;
  final IAuthRemoteDS _authRemoteDS;

  Future<void> loadSettings() async {
    emit(const NotificationSettingsState.loading());
    try {
      // Используем .value (синхронный геттер), а не .getValue()
      final enabled = _authDao.notificationsEnabled.value ?? true;
      emit(NotificationSettingsState.loaded(isEnabled: enabled));
    } catch (e) {
      emit(NotificationSettingsState.error(message: e.toString()));
    }
  }

  Future<void> toggleNotifications(bool isEnabled) async {
    try {
      // Сохраняем локально
      await _authDao.notificationsEnabled.setValue(isEnabled);

      // Подписываем/отписываем от топиков через ваш NotificationService
      if (isEnabled) {
        await _notificationService.subscribeToTopic(topic: 'all');
      } else {
        await _notificationService.unsubscribeFromTopic(topic: 'all');
      }

      final deviceToken = _authDao.deviceToken.value;
      if (deviceToken != null) {
        await _authRemoteDS.updateNotificationSettings(
          enabled: isEnabled,
          deviceToken: deviceToken,
        );
      }

      // Обновляем состояние
      emit(NotificationSettingsState.loaded(isEnabled: isEnabled));
    } catch (e) {
      emit(NotificationSettingsState.error(message: e.toString()));
      // Откатываем состояние при ошибке
      await loadSettings();
    }
  }
}
