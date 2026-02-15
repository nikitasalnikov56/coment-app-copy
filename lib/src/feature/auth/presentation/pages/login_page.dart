import 'dart:developer';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/presentation/widgets/dialog/toaster.dart';
import 'package:coment_app/src/core/presentation/widgets/other/custom_loading_overlay_widget.dart';
import 'package:coment_app/src/core/presentation/widgets/textfields/custom_validator_textfield.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/core/utils/input/validator_util.dart';
import 'package:coment_app/src/feature/app/bloc/app_bloc.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
import 'package:coment_app/src/feature/auth/bloc/login_cubit.dart';

@RoutePage()
class LoginPage extends StatefulWidget implements AutoRouteWrapper {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(repository: context.repository.authRepository, authDao: context.repository.authDao),
      child: this,
    );
  }
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ValueNotifier<String?> _phoneError = ValueNotifier(null);
  final ValueNotifier<String?> _passwordError = ValueNotifier(null);
  final MaskTextInputFormatter maskFormatter = MaskTextInputFormatter(mask: '+7(###) ###-##-##');
  final ValueNotifier<bool> _obscureText = ValueNotifier(true);
  final ValueNotifier<bool> _allowTapButton = ValueNotifier(false);
  final ValueNotifier<String?> _emailError = ValueNotifier(null);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _obscureText.dispose();
    _passwordError.dispose();
    _phoneError.dispose();
    _emailError.dispose();
    _allowTapButton.dispose();
    super.dispose();
  }

  void checkAllowTapButton() {
    // Validate email and password fields
    final isEmailValid = ValidatorUtil.emailValidator(
          emailController.text,
          errorLabel: 'Неверный логин',
        ) ==
        null; // Ensure no error is returned
    final isPasswordValid = passwordController.text.isNotEmpty;

    // Enable the button only if both fields are valid
    _allowTapButton.value = isEmailValid && isPasswordValid;
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      overlayColor: AppColors.barrierColor,
      overlayWidgetBuilder: (progress) => const CustomLoadingOverlayWidget(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          state.maybeWhen(
            loading: () => context.loaderOverlay.show(),
            error: (message, sendedOldValue, authErrorResponse) {
              context.loaderOverlay.hide();
              Toaster.showErrorTopShortToast(context, message);
              Future<void>.delayed(
                const Duration(milliseconds: 300),
              ).whenComplete(
                () => _formKey.currentState!.validate(),
              );
            },
            loaded: (user) {
              context.loaderOverlay.hide();
              BlocProvider.of<AppBloc>(context).add(AppEvent.logining(user: user));
              context.router.replaceAll([LauncherRoute()]);
              Toaster.showTopShortToast(context, message: 'Успешно');
              log('loaded', name: 'login page loaded');
            },
            orElse: () => context.loaderOverlay.hide(),
          );
        },
        builder: (context, state) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            onPanDown: (details) {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              appBar: CustomAppBar(
                actions: [
                  Container(
                    width: 40,
                  )
                ],
              ),
              body: SingleChildScrollView(
                child: SafeArea(
                  child: Form(
                    key: _formKey,
                    // autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap(70),
                          Text(
                            context.localized.login,
                            style: AppTextStyles.fs26w700.copyWith(height: 1.25),
                          ),
                          const Gap(20),
                          Text(
                            context.localized.enterYourEmailAddress,
                            style: AppTextStyles.fs14w500.copyWith(height: 1.3),
                          ),
                          const Gap(8),
                          SizedBox(
                            height: 44,
                            child: CustomValidatorTextfield(
                              controller: emailController,
                              valueListenable: _emailError,
                              hintText: context.localized.email,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (value) {
                                checkAllowTapButton();
                              },
                              validator: (String? value) {
                                return null;

                                // return _emailError.value = ValidatorUtil.emailValidator(
                                //   emailController.text,
                                //   errorLabel: 'Неверный логин',
                                // );
                              },
                            ),
                          ),
                          const Gap(16),
                          Text(
                             '${context.localized.enterThePassword} (${context.localized.helperText})',
                            style: AppTextStyles.fs14w500.copyWith(height: 1.3),
                          ),
                          const Gap(8),
                          ValueListenableBuilder(
                            valueListenable: _obscureText,
                            builder: (context, v, c) {
                              return CustomValidatorTextfield(
                                obscureText: _obscureText,
                                controller: passwordController,
                                valueListenable: _passwordError,
                                hintText: context.localized.password,
                                onChanged: (value) {
                                  if (value.isEmpty) {
                                  _passwordError.value =
                                      context.localized.required_to_fill;
                                } else if (value.length < 9) {
                                  _passwordError.value =
                                      context.localized.minCharacters;
                                } else {
                                  _passwordError.value = null;
                                }
                                  checkAllowTapButton();
                                },
                                validator: null,
                              );
                            },
                          ),
                          const Gap(8),
                          GestureDetector(
                            onTap: () {
                              context.router.push(const PasswordRecoveryRoute());
                              // context.router.push(EnterSmsCodeRoute(
                              //     email: emailController.text, flowType: EnterSmsCodeType.forgotPassword));
                            },
                            child: Text(
                              context.localized.forgotYourPassword,
                              style: AppTextStyles.fs14w500.copyWith(height: 1.3),
                            ),
                          ),
                          const Gap(34),
                          CustomButton(
                            allowTapButton: _allowTapButton,
                            onPressed: () {
                              if (!_formKey.currentState!.validate()) return;
                              BlocProvider.of<LoginCubit>(context).login(
                                email: emailController.text,
                                password: passwordController.text,
                                deviceType: Platform.isAndroid ? 'Android' : 'IOS',
                              );
                            },
                            style: CustomButtonStyles.mainButtonStyle(context),
                            text: context.localized.loginToAcc,
                            child: null,
                          ),
                          const Gap(10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
