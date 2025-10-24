import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';

import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';

@RoutePage()
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Gap(56),

                SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: Image.asset(AssetsConstants.launchPageImg),
                ),
                const Gap(43),

                const Text(
                  'Исследуйте приложение',
                  style: AppTextStyles.fs26w700,
                ),
                const Gap(16),
                // Description section
                const Text(
                  'Подарки в пару кликов — быстро, стильно, с душой!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.fs16w400,
                ),
                const Spacer(),
                const Gap(76),
                // Login button
                CustomButton(
                  onPressed: () {
                    context.router.push(const LoginRoute());
                  },
                  style: CustomButtonStyles.mainButtonStyle(context),
                  text: 'Войти',
                  child: null,
                ),
                const Gap(16),
                CustomButton(
                  onPressed: () {
                    context.router.push(const RegisterRoute());
                  },
                  style: CustomButtonStyles.primaryButtonStyle(context),
                  text: 'Создать аккаунт',
                  child: null,
                ),
                // const Gap(36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
