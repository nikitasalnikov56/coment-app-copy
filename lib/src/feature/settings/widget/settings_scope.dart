import 'package:coment_app/src/feature/auth/bloc/register_cubit.dart';
import 'package:coment_app/src/feature/catalog/model/create_product_model.dart';
import 'package:coment_app/src/feature/main/bloc/dictionary_cubit.dart';
import 'package:coment_app/src/feature/profile/bloc/profile_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coment_app/src/core/utils/extensions/context_extension.dart';

import 'package:coment_app/src/feature/app/bloc/app_bloc.dart';

import 'package:coment_app/src/feature/app/initialization/widget/dependencies_scope.dart';

import 'package:coment_app/src/feature/settings/bloc/app_settings_bloc.dart';
import 'package:coment_app/src/feature/settings/model/app_settings.dart';
import 'package:provider/provider.dart';

/// {@template settings_scope}
/// SettingsScope widget.
/// {@endtemplate}
class SettingsScope extends StatefulWidget {
  /// {@macro settings_scope}
  const SettingsScope({
    required this.child,
    super.key,
  });

  /// The child widget.
  final Widget child;

  /// Get the [AppSettingsBloc] instance.
  static AppSettingsBloc of(
    BuildContext context, {
    bool listen = true,
  }) {
    final settingsScope = listen
        ? context.dependOnInheritedWidgetOfExactType<_InheritedSettings>()
        : context.getInheritedWidgetOfExactType<_InheritedSettings>();
    return settingsScope!.state._appSettingsBloc;
  }

  /// Get the [AppSettings] instance.
  static AppSettings settingsOf(
    BuildContext context, {
    bool listen = true,
  }) {
    final settingsScope = listen
        ? context.dependOnInheritedWidgetOfExactType<_InheritedSettings>()
        : context.getInheritedWidgetOfExactType<_InheritedSettings>();
    return settingsScope!.settings ?? const AppSettings();
  }

  @override
  State<SettingsScope> createState() => _SettingsScopeState();
}

/// State for widget SettingsScope.
class _SettingsScopeState extends State<SettingsScope> {
  // static const BlocScope<SettingsEvent, SettingsState, SettingsBloc> _scope = BlocScope();

  late final AppSettingsBloc _appSettingsBloc;

  //  static ScopeData<AppLanguage> get appLanguageOf => _scope.select(_locale);

  @override
  void initState() {
    _appSettingsBloc = DependenciesScope.of(context).appSettingsBloc;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<AppSettingsBloc, AppSettingsState>(
        bloc: _appSettingsBloc,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AppBloc(context.repository.authRepository),
            ),
            BlocProvider(
              create: (context) => ProfileBLoC(
                authRepository: context.repository.authRepository,
                profileRepository: context.repository.profileRepository,
              ),
            ),
            BlocProvider(
              create: (context) => DictionaryCubit(
                repository: context.repository.mainRepository,
              ),
            ),
            BlocProvider(
              create: (context) => RegisterCubit(
                repository: context.repository.authRepository,
                authDao: context.repository.authDao,
              ),
            ),
            ChangeNotifierProvider(
              create: (context) => CreateProductModel(),
            ),
          ],
          child: _InheritedSettings(
            settings: state.appSettings,
            state: this,
            child: widget.child,
          ),
        ),
      );
}

/// {@template inherited_settings}
/// _InheritedSettings widget.
/// {@endtemplate}
class _InheritedSettings extends InheritedWidget {
  /// {@macro inherited_settings}
  const _InheritedSettings({
    required super.child,
    required this.state,
    required this.settings, // ignore: unused_element
  });

  /// _SettingsScopeState instance.
  final _SettingsScopeState state;
  final AppSettings? settings;

  @override
  bool updateShouldNotify(covariant _InheritedSettings oldWidget) => settings != oldWidget.settings;
}
