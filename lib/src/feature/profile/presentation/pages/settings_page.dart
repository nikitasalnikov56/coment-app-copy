import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/profile/bloc/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Настройки',
        shape: Border(
          bottom: BorderSide(
            color: AppColors.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      // AppBar(title: const Text('Настройки')),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          // Используем maybeMap или map, так как ProfileState — это Union тип в freezed
          return state.maybeMap(
            loaded: (loadedState) {
              final user = loadedState.userDTO;

              return ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          // color: user.showRealName == false ? AppColors.barrierColor : AppColors.green,
                          color: user.showRealName == false ? AppColors.barrierColor : AppColors.mainColor,
                          offset: Offset.fromDirection(2),
                          spreadRadius: 1,
                          blurRadius: 5
                        ),
                      ],
                    ),
                    child: SwitchListTile(
                      inactiveThumbColor: AppColors.grey969696,
                      inactiveTrackColor: AppColors.greyText,
                      // activeColor: AppColors.green,
                      activeColor: AppColors.mainColor,
                      activeTrackColor: AppColors.greyText,
                      trackOutlineColor:
                          WidgetStateProperty.all(AppColors.backgroundColor),
                      thumbIcon: WidgetStatePropertyAll(
                        Icon(
                          user.showRealName == false
                              ? Icons.close
                              : Icons.check,
                          color: user.showRealName == false
                              ? AppColors.white
                              : AppColors.white,
                        ),
                      ),
                      title: Text(
                        user.showRealName == false
                            ? 'ФИО: ${user.name ?? user.username}'
                            : 'Имя пользователя: @${user.username}',
                        style: AppTextStyles.fs14w600.copyWith(
                          color: AppColors.black,
                          fontSize: 15,
                          letterSpacing: 1.5,
                        ),
                      ),
                      // Используем ?? false, так как в DTO поле может быть null
                      value: user.showRealName ?? false,
                      onChanged: (bool value) {
                        context.read<ProfileCubit>().updateShowRealName(value);
                      },
                    ),
                  ),
                ],
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
