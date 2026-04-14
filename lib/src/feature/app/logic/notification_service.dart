import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/feature/app/logic/reactivex_service.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
import 'package:coment_app/src/feature/auth/data/auth_remote_ds.dart';
import 'package:coment_app/src/feature/auth/models/user_dto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:coment_app/src/feature/app/logic/push_data_dto.dart';
import 'package:coment_app/src/feature/auth/database/auth_dao.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const _tag = 'NotificationService';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.high,
);

class NotificationService {
  NotificationService();
  late FirebaseMessaging _messaging;

  Future<void> init() async {
    _messaging = FirebaseMessaging.instance;
    _messaging
        .getInitialMessage()
        .then((value) => log('Message is $value', name: _tag));

    await _requestPermissionToNotifications(_messaging);

    // if (Platform.isIOS) {
    //   await _requestPermissionToNotifications(_messaging);
    // }
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
    _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOs = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOs,
    );
    // ignore: avoid-ignoring-return-values
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      final RemoteNotification? notification = event.notification;
      log('event˝ data --- ${event.data}', name: _tag);

      ///
      /// parse zone
      ///
      try {
        final data = PushDataDTO.fromJson(event.data);
        ReactiveXService().pushRepeater.sink.add(data);
      } catch (e) {
        log('catch - $e', name: _tag);
        rethrow;
      }

      final AndroidNotification? android =
          Platform.isAndroid ? event.notification?.android : null;

      if (notification != null) {
        if (Platform.isAndroid && android != null) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                icon: '@mipmap/ic_launcher',
              ),
            ),
          );
        }
      }
    });
  }

  Future<void> onMessageOpenedApp(BuildContext context) async {
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        if (!context.mounted) return;
        _handleOnTap(message, context);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      if (!context.mounted) return;
      _handleOnTap(event, context);
    });
  }

  void _handleOnTap(RemoteMessage event, BuildContext context) {
    log('"ONTAP:::" data --- ${event.data}', name: _tag);
    log('"ONTAP:" data --- ${event.data['type']}', name: _tag);

    try {
      final data = PushDataDTO.fromJson(event.data);
      final idStr = data.feedbackId?.trim();

      if (idStr == null || idStr.isEmpty || idStr == '0') {
        log('Invalid feedbackId in push: $idStr', name: _tag);
        // Можно показать общий экран каталога или ничего не делать
        context.router.navigate(LauncherRoute());
        return;
      }

      final id = int.tryParse(idStr);
      if (id == null || id <= 0) {
        log('Invalid feedbackId number: $idStr', name: _tag);
        context.router.navigate(LauncherRoute());
        return;
      }

      context.router.replaceAll([
        LauncherRoute(),
        FeedbackDetailRoute(id: id, userId: 0, needPageCard: true),
      ]);
    } catch (e, stackTrace) {
      log('Error navigating to detail screen: $e\n$stackTrace', name: _tag);
      // На всякий — fallback
      context.router.navigate(LauncherRoute());
    }
  }

  Future<String?> getDeviceToken({
    required IAuthDao authDao,
  }) async {
    final String? deviceToken = await FirebaseMessaging.instance.getToken();
    if (deviceToken != null) {
      await authDao.deviceToken.setValue(deviceToken);
    }
    log('$deviceToken', name: _tag);
    return deviceToken;
  }

  Future<void> _requestPermissionToNotifications(
    FirebaseMessaging messaging,
  ) async {
    final NotificationSettings settings = await messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('User granted provisional permission');
      }
    } else {
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      }
    }
  }

  Future<void> subscribeToTopic({
    required String topic,
  }) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic('push_$topic');
    } catch (e) {
      log('$e', name: _tag);
    }
  }

  Future<void> unsubscribeFromTopic({
    required String topic,
  }) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic('push_$topic');
    } catch (e) {
      log('$e', name: _tag);
    }
  }

  /// Включает/выключает уведомления
  Future<void> setNotificationsEnabled({
    required bool enabled,
    required IAuthDao authDao,
    required IAuthRemoteDS
        authRemoteDS, // ← передаём remote DS для API-запросов
  }) async {
    try {
      // 1. Сохраняем локально (используем .value и .setValue())
      await authDao.notificationsEnabled.setValue(enabled);

      // 2. Подписываем/отписываем от топиков
      if (enabled) {
        await subscribeToTopic(topic: 'all');
      } else {
        await unsubscribeFromTopic(topic: 'all');
      }

      // 2. Получаем токен и тип устройства
      final deviceToken = authDao.deviceToken.value;
      // final deviceType = Platform.isAndroid ? 'android' : 'ios';

      if (deviceToken != null) {
        await authRemoteDS.updateNotificationSettings(
          deviceToken: deviceToken,
          enabled: enabled,
        );
      }

      // // 3. Если пользователь авторизован — отправляем предпочтение на бэкенд
      // final userStr = authDao.user.value; // ← .value, не .getValue()
      // if (userStr != null && userStr != 'null') {
      //   final user =
      //       UserDTO.fromJson(jsonDecode(userStr) as Map<String, dynamic>);
      //   if (user.accessToken != null) {
      //     await _sendNotificationPreferenceToBackend(
      //       enabled,
      //       user.accessToken!,
      //       authRemoteDS, // ← используем remote DS для запроса
      //       deviceToken,
      //     );
      //   }
      // }
    } catch (e) {
      log('Failed to set notification preference: $e', name: _tag);
      rethrow;
    }
  }

  /// Получает текущее состояние уведомлений
  Future<bool> getNotificationsEnabled(IAuthDao authDao) async {
    // ← .value возвращает T?, не нужен await
    return authDao.notificationsEnabled.value ?? true;
  }

  /// Отправляет предпочтение на бэкенд
  Future<void> _sendNotificationPreferenceToBackend(
    bool enabled,
    String accessToken,
    IAuthRemoteDS authRemoteDS, // ← интерфейс для API
    String? deviceToken,
  ) async {
    try {
      // Используем ваш существующий remote DS для отправки
      await authRemoteDS.updateNotificationSettings(
        enabled: enabled,
        deviceToken: deviceToken,
        // deviceToken можно получить отдельно, если нужно
      );
    } catch (e) {
      log('Failed to send notification preference to backend: $e', name: _tag);
      // Не выбрасываем ошибку, чтобы не ломать локальное сохранение
    }
  }
}
