import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/auth/models/user_dto.dart';
import 'package:coment_app/src/feature/profile/bloc/notification_settings_cubit.dart';
import 'package:coment_app/src/feature/profile/bloc/profile_cubit.dart';
import 'package:coment_app/src/feature/settings/bloc/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        // Используем maybeMap или map, так как ProfileState — это Union тип в freezed
        return state.maybeMap(
          loaded: (loadedState) {
            final user = loadedState.userDTO;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 60,
                  child: WidgetSwitchListTile(
                    user: user,
                    icon: Icons.alternate_email,
                    title: user.showRealName == false
                        ? '${user.name ?? user.username}'
                        : ' ${user.username}',
                    subTitle: user.showRealName == false
                        ? context.localized.fio
                        : context.localized.userName,
                    value: user.showRealName ?? false,
                    onChanged: (bool value) {
                      context.read<ProfileCubit>().updateShowRealName(value);
                    },
                  ),
                ),
                NotificationSettingsWidget(user: user),
                WidgetSwitchListTile(
                  user: user,
                  icon: Icons.dark_mode_outlined,
                  title: context.localized.darkTheme,
                  subTitle: null,
                  value: context.watch<ThemeCubit>().state.maybeWhen(
                        loaded: (themeMode) => themeMode == ThemeMode.dark,
                        orElse: () => false,
                      ),
                  onChanged: (bool value) {
                    context.read<ThemeCubit>().toggleTheme(value);
                  },
                ),
              ],
            );
          },
          loading: (_) => const Center(child: CircularProgressIndicator()),
          error: (errorState) => Center(child: Text(errorState.message)),
          orElse: () =>  Center(child: Text('${context.localized.profileLoading}...')),
        );
      },
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
        return SizedBox(
          height: 55,
          child: WidgetSwitchListTile(
            user: user,
            icon: Icons.notifications,
            title: context.localized.notifications,
            subTitle: null,
            value: state.maybeWhen(
              orElse: () => false,
              loaded: (isEnabled) => isEnabled,
            ),
            onChanged: (bool value) {
              context
                  .read<NotificationSettingsCubit>()
                  .toggleNotifications(value);
            },
          ),
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
    this.subTitle,
  });

  final UserDTO user;
  final bool value;
  final IconData? icon;
  final Function(bool)? onChanged;
  final String? title;
  final String? subTitle;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
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
      secondary: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0x33BBB5FE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 20,
          color: Theme.of(context).appBarTheme.iconTheme?.color,
        ),
      ),
      title: Text(
        title ?? '',
        style: AppTextStyles.fs16w500.copyWith(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: subTitle != null
          ? Text(
              subTitle!,
              style: AppTextStyles.fs12w400.copyWith(
                color: AppColors.greyTextColor,
              ),
            )
          : null,
      // Используем ?? false, так как в DTO поле может быть null
      value: value,
      onChanged: onChanged,
    );
  }
}
