import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;
import 'package:coment_app/firebase_options.dart';
import 'package:coment_app/src/feature/app/logic/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coment_app/src/core/constant/config.dart';
import 'package:coment_app/src/core/utils/app_bloc_observer.dart';
import 'package:coment_app/src/core/utils/refined_logger.dart';
import 'package:coment_app/src/core/utils/talker_logger_util.dart';
import 'package:coment_app/src/feature/app/bloc/app_restart_bloc.dart';
import 'package:coment_app/src/feature/app/presentation/app.dart';
import 'package:coment_app/src/feature/app/initialization/logic/composition_root.dart';
import 'package:coment_app/src/feature/app/initialization/widget/initialization_failed_app.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';

final class AppRunner {
  const AppRunner();

  Future<void> initializeAndRun() async {
    final binding = WidgetsFlutterBinding
        .ensureInitialized(); // 1. Гарантирует, что Flutter готов к работе.

    binding
        .deferFirstFrame(); // 2. Задерживает отрисовку первого кадра до завершения инициализации.

    // Настройка логгирования (оставляем как было)
    FlutterError.onError =
        logger.logFlutterError; // 3. Перехват ошибок Flutter Framework.
    WidgetsBinding.instance.platformDispatcher.onError =
        logger.logPlatformDispatcherError; // 4. Перехват ошибок платформы.

    // Настройка BLoC (полностью сохраняем)
    if (kDebugMode) {
      // 5. Проверяет, запущено ли приложение в режиме отладки.
      Bloc.observer = TalkerBlocObserver(
        // В режиме отладки используется подробный логгер для BLoC.
        talker: TalkerLoggerUtil
            .talker, //Конструктор TalkerBlocObserver требует экземпляр Talker, чтобы знать, куда именно выводить логи.
// TalkerLoggerUtil — это ваш собственный класс-утилита в проекте (src/core/utils/talker_logger_util.dart). 
//Он создает и хранит один-единственный (singleton) экземпляр Talker.
// Передавая TalkerLoggerUtil.talker сюда, вы гарантируете, что логи от BLoC'ов будут 
//идти в тот же централизованный логгер, что и все остальные логи вашего приложения (например, логи сетевых запросов).

        settings: const TalkerBlocLoggerSettings( //Этот параметр позволяет тонко настроить, как именно TalkerBlocObserver будет логировать информацию.
          printStateFullData: false,//Это очень важная настройка. Ваши классы состояний (например, LoginState, 
          // ProductListState) созданы с помощью freezed. По умолчанию, freezed генерирует очень 
          //подробный метод toString(), который выводит имя класса и значения всех его полей.
// Если у вас в состоянии хранится большой список объектов (например, 100 товаров), 
//то при каждом изменении состояния в консоль будет выводиться огромный "пласт" текста, что сделает логи нечитаемыми.
// Установка printStateFullData: false говорит логгеру: 
//"Не нужно печатать все данные состояния. Просто напиши его имя, например, LoginState.loading() 
//или ProductListState.loaded". Это делает лог событий BLoC кратким и информативным.
        ),
      );
    } else {
      Bloc.observer = AppBlocObserver(logger);// 6. В релизе - кастомный наблюдатель для отправки ошибок в Sentry.
    }
    Bloc.transformer = bloc_concurrency.sequential(); // 7. Все события в BLoC обрабатываются строго по очереди.

    const config = Config(); // 8. Создание объекта конфигурации для доступа к переменным окружения.

    try {
      // Инициализация Firebase только для мобильных платформ
      if (!kIsWeb) {
        try {
          await Firebase.initializeApp(// 10. Инициализация Firebase с нужными ключами из firebase_options.dart.

            options: DefaultFirebaseOptions.currentPlatform,
          );
          await NotificationService().init();// 11. Инициализация сервиса push-уведомлений.

        } catch (e) {
          if (kDebugMode) print('Firebase init error: $e');
        }
      }

      // Основная инициализация приложения (без изменений)
      final result = await CompositionRoot(config, logger).compose(); // 12. Создание всех зависимостей приложения.

      TalkerLoggerUtil.talker.log('msSpent ${result.msSpent}');

      runApp(
        BlocProvider(
          create: (context) => AppRestartBloc(),// 14. Предоставление BLoC для возможности перезапуска приложения.
          child: App(result: result), // 15. Корневой виджет приложения, куда передаются все зависимости.
        ),
      );
    } catch (e, stackTrace) {
      TalkerLoggerUtil.talker.error('Initialization failed', e, stackTrace);
      logger.error('Initialization failed', error: e, stackTrace: stackTrace);
// ... Обработка ошибок инициализации
      runApp(// 16. Если что-то пошло не так на старте, показываем специальный экран ошибки.
        InitializationFailedApp( 
          error: e,
          stackTrace: stackTrace,
          retryInitialization: initializeAndRun,
        ),
      );
      rethrow; // 17. Пробрасываем ошибку дальше, чтобы она была видна в логах/Sentry.
    } finally {
      if (!binding.firstFrameRasterized) binding.allowFirstFrame();// 18. Разрешаем отрисовку первого кадра в любом случае.
    }
  }
}
