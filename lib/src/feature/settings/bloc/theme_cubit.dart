import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:coment_app/src/feature/settings/data/app_settings_repository.dart';
import 'package:coment_app/src/feature/settings/model/app_settings.dart';
import 'package:coment_app/src/feature/app/model/app_theme.dart';

part 'theme_cubit.freezed.dart';

@freezed
class ThemeState with _$ThemeState {
  const factory ThemeState.initial() = _Initial;
  const factory ThemeState.loading() = _Loading;
  const factory ThemeState.loaded({required ThemeMode themeMode}) = _Loaded;
  const factory ThemeState.error({required String message}) = _Error;
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({required AppSettingsRepository settingsRepository})
      : _settingsRepository = settingsRepository,
        super(const ThemeState.initial());

  final AppSettingsRepository _settingsRepository;

  /// Загружает сохранённую тему или системную по умолчанию
  Future<void> loadTheme() async {
    emit(const ThemeState.loading());
    try {
      final settings = await _settingsRepository.getAppSettings();
      // Если тема сохранена — используем её, иначе — системная
      final themeMode = settings?.appTheme?.themeMode ?? ThemeMode.system;
      emit(ThemeState.loaded(themeMode: themeMode));
    } catch (e) {
      emit(ThemeState.error(message: e.toString()));
      // В продакшене можно добавить логирование
    }
  }

  /// Переключает тему: true = dark, false = light
  Future<void> toggleTheme(bool isDark) async {
    try {
      final currentSettings = await _settingsRepository.getAppSettings() ?? const AppSettings();
      final newThemeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      
      final updatedAppTheme = AppTheme(
        themeMode: newThemeMode,
        seed: currentSettings.appTheme?.seed ?? Colors.blue,
      );
      
      final updatedSettings = currentSettings.copyWith(
        appTheme: updatedAppTheme,
      );
      
      await _settingsRepository.setAppSettings(updatedSettings);
      emit(ThemeState.loaded(themeMode: newThemeMode));
    } catch (e) {
      emit(ThemeState.error(message: e.toString()));
    }
  }

  /// Вспомогательный геттер для текущего режима
  ThemeMode get currentThemeMode {
    final state = this.state;
    if (state is _Loaded) {
      return state.themeMode;
    }
    return ThemeMode.system;
  }
}