import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/auth/models/user_dto.dart';
import 'package:coment_app/src/feature/profile/bloc/notification_settings_cubit.dart';
import 'package:coment_app/src/feature/profile/bloc/profile_cubit.dart';
import 'package:coment_app/src/feature/settings/bloc/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: context.localized.settings,
        shape: const Border(
          bottom: BorderSide(
            color: AppColors.dividerColor,
            width: 0.5,
          ),
        ),
        actions: const [
          SizedBox(
            width: 50,
          )
        ],
      ),
      // AppBar(title: const Text('Настройки')),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          // Используем maybeMap или map, так как ProfileState — это Union тип в freezed
          return state.maybeMap(
            loaded: (loadedState) {
              final user = loadedState.userDTO;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border.all(
                      color: AppColors.grey969696,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(
                      16,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WidgetSwitchListTile(
                        user: user,
                        icon: Icons.person,
                        title: user.showRealName == false
                            ? '${context.localized.fio}:'
                            : '${context.localized.userName}:',
                        subTitle: user.showRealName == false
                            ? '${user.name ?? user.username}'
                            : ' @${user.username}',
                        titleStyle: AppTextStyles.fs14w600.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 15,
                          letterSpacing: 1.5,
                        ),
                        subTitleStyle: AppTextStyles.fs14w600.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 13,
                          letterSpacing: 1.5,
                        ),
                        value: user.showRealName ?? false,
                        onChanged: (bool value) {
                          context
                              .read<ProfileCubit>()
                              .updateShowRealName(value);
                        },
                      ),
                      const Divider(
                        thickness: 2,
                        indent: 65,
                      ),
                      NotificationSettingsWidget(user: user),
                      const Divider(
                        thickness: 2,
                        indent: 65,
                      ),
                      WidgetSwitchListTile(
                        user: user,
                        icon: Icons.dark_mode_outlined,
                        title: 'Темная тема',
                        subTitle: null,
                        value: context.watch<ThemeCubit>().state.maybeWhen(
                              loaded: (themeMode) =>
                                  themeMode == ThemeMode.dark,
                              orElse: () => false,
                            ),
                        onChanged: (bool value) {
                          context.read<ThemeCubit>().toggleTheme(value);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: (_) => const Center(child: CircularProgressIndicator()),
            error: (errorState) => Center(child: Text(errorState.message)),
            orElse: () => const Center(child: Text('Загрузка профиля...')),
          );
        },
      ),
    );
  }
}

class NotificationSettingsWidget extends StatelessWidget {
  const NotificationSettingsWidget({
    super.key,
    required this.user,
  });

  final UserDTO user;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationSettingsCubit, NotificationSettingsState>(
      builder: (context, state) {
        return WidgetSwitchListTile(
          user: user,
          icon: Icons.notifications,
          title: 'Уведомления',
          subTitle: null,
          value: state.maybeWhen(orElse: ()=> false,
          loaded: (isEnabled) => isEnabled,),
          onChanged: (bool value) {
            context.read<NotificationSettingsCubit>().toggleNotifications(value);
          },
        );
      },
    );
  }
}

class WidgetSwitchListTile extends StatelessWidget {
  const WidgetSwitchListTile({
    super.key,
    required this.user,
    required this.value,
    required this.onChanged,
    this.icon,
    this.title,
    this.titleStyle,
    this.subTitle,
    this.subTitleStyle,
  });

  final UserDTO user;
  final bool value;
  final IconData? icon;
  final Function(bool)? onChanged;
  final String? title;
  final String? subTitle;
  final TextStyle? titleStyle;
  final TextStyle? subTitleStyle;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      inactiveThumbColor: AppColors.grey969696,
      inactiveTrackColor: AppColors.greyText,
      // activeColor: AppColors.green,
      activeColor: AppColors.mainColor,
      activeTrackColor: AppColors.greyText,
      trackOutlineColor: WidgetStateProperty.all(AppColors.backgroundColor),
      thumbIcon: WidgetStatePropertyAll(
        Icon(
          user.showRealName == false ? Icons.close : Icons.check,
          color: user.showRealName == false ? AppColors.white : AppColors.white,
        ),
      ),
      secondary: Icon(
        icon,
        size: 35,
        color: Theme.of(context).iconTheme.color,
      ),
      title: Text(
        title ?? '',
        style: titleStyle,
      ),
      subtitle: subTitle != null
          ? Text(
              subTitle!,
              style: subTitleStyle,
            )
          : null,
      // Используем ?? false, так как в DTO поле может быть null
      value: value,
      onChanged: onChanged,
    );
  }
}
