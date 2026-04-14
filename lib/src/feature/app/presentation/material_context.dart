import 'package:coment_app/src/feature/settings/bloc/theme_cubit.dart';
import 'package:flutter/material.dart';

import 'package:coment_app/src/core/constant/localization/localization.dart';

import 'package:coment_app/src/core/theme/resources.dart';

import 'package:coment_app/src/feature/app/presentation/widgets/app_router_builder.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';

import 'package:coment_app/src/feature/settings/widget/settings_scope.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template material_context}
/// [MaterialContext] is an entry point to the material context.
///
/// This widget sets locales, themes and routing.
/// {@endtemplate}
class MaterialContext extends StatelessWidget {
  /// {@macro material_context}
  const MaterialContext({super.key});

  // This global key is needed for [MaterialApp]
  // to work properly when Widgets Inspector is enabled.
  // static final _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.settingsOf(context);
    final mediaQueryData = MediaQuery.of(context);

    return AppRouterBuilder(
      createRouter: (context) => AppRouter(),
      builder: (context, informationParser, routerDelegate, router) =>
          MaterialApp.router(
        title: 'coment_app',
        onGenerateTitle: (context) => 'coment_app',
        routerDelegate: routerDelegate,
        routeInformationParser: informationParser,
        themeMode: context.watch<ThemeCubit>().state.maybeWhen(
          loaded: (themeMode) => themeMode,
              orElse: () => ThemeMode.system,
            ),
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: Localization.localizationDelegates,
        supportedLocales: Localization.supportedLocales,
        locale: settings.locale?.languageCode == null ||
                settings.locale?.languageCode == ''
            ? const Locale('en')
            : settings.locale,
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          // Если пользователь вручную в приложении НЕ выбирал язык
          if (settings.locale == null) {
            return const Locale('en'); // Возвращаем английский по умолчанию
          }
          return settings.locale; // Иначе используем то, что выбрал юзер
        },
        builder: (context, child) => MediaQuery(
          // key: _globalKey,
          data: mediaQueryData.copyWith(
            textScaler: TextScaler.linear(
              mediaQueryData.textScaler
                  .scale(settings.textScale ?? 1)
                  .clamp(0.5, 2),
            ),
          ),
          child: child!,
        ),
      ),
    );
  }
}
