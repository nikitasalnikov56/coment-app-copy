import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/presentation/widgets/textfields/custom_textfield.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gcaptcha_v3/web_view.dart';
import 'package:gap/gap.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/presentation/widgets/dialog/toaster.dart';
import 'package:coment_app/src/core/presentation/widgets/other/custom_loading_overlay_widget.dart';
import 'package:coment_app/src/core/presentation/widgets/textfields/custom_validator_textfield.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/core/utils/input/validator_util.dart';
import 'package:coment_app/src/feature/app/bloc/app_bloc.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
import 'package:coment_app/src/feature/auth/bloc/register_cubit.dart';
import 'package:coment_app/src/feature/auth/models/common_dto.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

@RoutePage()
class RegisterPage extends StatefulWidget implements AutoRouteWrapper {
  const RegisterPage({
    super.key,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RegisterCubit(
            repository: context.repository.authRepository,
            authDao: context.repository.authDao,
          ),
          child: this,
        ),
      ],
      child: this,
    );
  }
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController surnameNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  final ValueNotifier<bool> _obscureText = ValueNotifier(true);
  final ValueNotifier<String?> _passwordError = ValueNotifier(null);
  final ValueNotifier<String?> _phoneError = ValueNotifier(null);
  final ValueNotifier<String?> _surnameNameError = ValueNotifier(null);
  final ValueNotifier<String?> _classError = ValueNotifier(null);
  final ValueNotifier<bool> _allowTapButton = ValueNotifier(false);
  final ValueNotifier<String?> _emailError = ValueNotifier(null);
  final ValueNotifier<String?> birthDateError = ValueNotifier(null);
  CommonDTO? chosenClass;
  final String _prefix = "+";
  final FocusNode _focusNode = FocusNode();
  Country? selectedCountry;

  @override
  void initState() {
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        if (phoneController.text.isEmpty) {
          phoneController.text = _prefix;
        }
        // Ставим курсор после "+7(7"
        phoneController.selection = TextSelection.fromPosition(
          TextPosition(offset: phoneController.text.length),
        );
      } else {
        // Если поле теряет фокус и введено только "+7(7", очищаем его
        if (phoneController.text == _prefix) {
          phoneController.clear();
        }
      }
      setState(() {}); // Обновляем UI
    });
    super.initState();
    selectedCountry = countries.first;
  }

  @override
  void dispose() {
    surnameNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    _surnameNameError.dispose();
    _classError.dispose();
    _emailError.dispose();
    passwordController.dispose();
    _allowTapButton.dispose();
    _focusNode.dispose();
    _phoneError.dispose();
    birthDateController.dispose();
    birthDateError.dispose();
    super.dispose();
  }

  bool checkAllowTapButton() {
    final isEmailValid = ValidatorUtil.emailValidator(
          emailController.text,
          errorLabel: 'Неверный логин',
        ) ==
        null;
    final isPasswordValid = passwordController.text.length >= 9;
    String phoneUnmasked =
        phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    bool isPhoneValid = phoneUnmasked.length == selectedCountry!.digitLength;
    return _allowTapButton.value = isPasswordValid &&
        isEmailValid &&
        surnameNameController.text.isNotEmpty &&
        isPhoneValid;
  }

  void showBirthdayPicker(
    BuildContext context, {
    required DateTime initialDate,
  }) {
    DateTime tempDate = initialDate;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Material(
        color: Colors.transparent,
        child: Container(
          height: 360,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // --- Верхняя панель (Отменить / Заголовок / Подтвердить)
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 18.0),
                      child: Text(
                        "Дата рождения",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Отменить",
                        style: AppTextStyles.fs16w400
                            .copyWith(color: AppColors.greyTextColor),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 0),
              // --- Пикер
              Expanded(
                flex: 3,
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontSize: 22,
                        color: CupertinoColors.black,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initialDate,
                    maximumDate: DateTime.now(),
                    minimumYear: 1900,
                    maximumYear: DateTime.now().year,
                    onDateTimeChanged: (DateTime value) {
                      tempDate = value;
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.transparent,
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 15),
                  child: CupertinoButton(
                    color: AppColors.mainColor,
                    minimumSize: Size(MediaQuery.of(context).size.width, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Подтвердить",
                      style: AppTextStyles.fs16w400
                          .copyWith(color: AppColors.kF5F6F7),
                    ),
                    onPressed: () {
                      if (tempDate != null) {
                        birthDateController.text =
                            tempDate.toIso8601String().split('T')[0];
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      overlayColor: AppColors.barrierColor,
      overlayWidgetBuilder: (progress) => const CustomLoadingOverlayWidget(),
      child: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          state.maybeWhen(
            loading: () => context.loaderOverlay.show(),
            error: (message) {
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
              BlocProvider.of<AppBloc>(context)
                  .add(AppEvent.logining(user: user));
              context.router.replaceAll([LauncherRoute()]);
              Toaster.showTopShortToast(context, message: 'Успешно');
            },
            orElse: () => context.loaderOverlay.hide(),
          );
        },
        builder: (context, state) {
          return GestureDetector(
            onTap: () {
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
              body: Form(
                key: _formKey,
                // autovalidateMode: AutovalidateMode.onUserInteraction,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Gap(70),
                        Text(
                          context.localized.accountRegister, //accountRegister
                          style: AppTextStyles.fs26w700.copyWith(height: 1.25),
                        ),
                        const Gap(8),
                        Text(
                          context.localized.joinInSecond, //joinInSecond
                          style: AppTextStyles.fs16w500.copyWith(height: 1.7),
                        ),
                        const Gap(20),
                        Text(
                          context
                              .localized.enterYourFullName, //enterYourFullName
                          style: AppTextStyles.fs14w500.copyWith(height: 1.3),
                        ),
                        const Gap(8),
                        SizedBox(
                          height: 44,
                          child: CustomValidatorTextfield(
                            controller: surnameNameController,
                            valueListenable: _surnameNameError,
                            hintText: context.localized.fullname, //fulname
                            onChanged: (value) {
                              checkAllowTapButton();
                            },
                            validator: (String? value) {
                              return null;

                              // if (value == null || value.isEmpty) {
                              //   return _surnameNameError.value = 'Обязательно к заполнению';
                              // }

                              // return _surnameNameError.value = null;
                            },
                          ),
                        ),
                        const Gap(16),
                        Text(
                          context.localized
                              .enterYourEmailAddress, // enterYourEmailAddress
                          style: AppTextStyles.fs14w500.copyWith(height: 1.3),
                        ),
                        const Gap(8),
                        CustomValidatorTextfield(
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
                        const Gap(16),
                        Text(
                          context.localized.enterYourBirthDate,
                          style: AppTextStyles.fs14w500.copyWith(height: 1.3),
                        ),
                        const Gap(8),
                        CustomValidatorTextfield(
                          controller: birthDateController,
                          valueListenable: birthDateError,
                          hintText: context.localized.enterYourBirthDate,
                          onTap: () => showBirthdayPicker(
                            context,
                            initialDate: DateTime.now().subtract(
                              const Duration(days: 18 * 365),
                            ),
                          ),
                        ),
                        const Gap(16),
                        Text(
                          context.localized.enterYourPhoneNumber,
                          style: AppTextStyles.fs14w500.copyWith(height: 1.3),
                        ),
                        const Gap(8),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                height: 44,
                                obscureText: false,
                                focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        width: 1,
                                        color: AppColors.borderTextField),
                                    borderRadius: BorderRadius.circular(12)),
                                prefixIconWidget: Padding(
                                  padding: const EdgeInsets.only(left: 18.0),
                                  child: DropdownButton<Country>(
                                    value: selectedCountry,
                                    borderRadius: BorderRadius.circular(12),
                                    items: countries.map((country) {
                                      return DropdownMenuItem<Country>(
                                        value: country,
                                        child: Text(
                                            '${country.name} ${country.code}'),
                                      );
                                    }).toList(),
                                    onChanged: (Country? newCountry) {
                                      if (newCountry != null) {
                                        setState(() {
                                          selectedCountry = newCountry;
                                          phoneController.clear();
                                        });
                                      }
                                    },
                                    dropdownColor: Colors.white,
                                    underline: const SizedBox(),
                                  ),
                                ),
                                controller: phoneController,
                                inputFormatters: [
                                  MaskTextInputFormatter(
                                    mask: selectedCountry!.mask,
                                    filter: {"#": RegExp(r'[0-9]')},
                                  ),
                                ],
                                keyboardType: TextInputType.phone,
                                hintText:
                                    selectedCountry!.mask.replaceAll('#', '_'),
                                onChanged: (value) {
                                  checkAllowTapButton();
                                },
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return _phoneError.value =
                                        context.localized.required_to_fill;
                                  }
                                  String unmasked =
                                      value.replaceAll(RegExp(r'[^0-9]'), '');
                                  if (unmasked.length !=
                                      selectedCountry!.digitLength) {
                                    // return _phoneError.value =
                                    //     context.localized.incorrectNumberFormat;
                                  }
                                  return _phoneError.value = null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const Gap(16),
                        Text(
                          '${context.localized.enterThePassword} (${context.localized.helperText})',
                          style: AppTextStyles.fs14w500.copyWith(height: 1.3),
                        ),
                        const Gap(6),
                        ValueListenableBuilder(
                          valueListenable: _obscureText,
                          builder: (context, v, c) {
                            return CustomValidatorTextfield(
                              obscureText: _obscureText,
                              controller: passwordController,
                              valueListenable: _passwordError,
                              hintText: context.localized.password,
                              onChanged: (value) {
                                checkAllowTapButton();
                              },
                              validator: (String? value) {
                                return null;

                                // if (value == null || value.isEmpty) {
                                //   return _passwordError.value = 'Обязательно к заполнению';
                                // }

                                // if (value.length < 6) {
                                //   return _passwordError.value = 'Минимальная длина пароля - 6';
                                // }

                                // return _passwordError.value = null;
                              },
                            );
                          },
                        ),
                        const Gap(34),
                        CustomButton(
                          allowTapButton: _allowTapButton,
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) return;
                            String nationalNumber = phoneController.text
                                .replaceAll(RegExp(r'[^0-9]'), '');
                            String fullPhoneNumber =
                                selectedCountry!.code + nationalNumber;
                            fullPhoneNumber = fullPhoneNumber
                                .trim(); // ← убираем пробелы в начале/конце
                            print(
                                'FINAL PHONE: "${fullPhoneNumber.runtimeType}"');

                            BlocProvider.of<RegisterCubit>(context).register(
                              email: emailController.text,
                              name: surnameNameController.text,
                              password: passwordController.text,
                              phone: fullPhoneNumber,
                              deviceType:
                                  Platform.isAndroid ? 'Android' : 'IOS',
                              birthDate: birthDateController.text,
                            );
                          },
                          style: CustomButtonStyles.mainButtonStyle(context),
                          text: context.localized.signUp,
                          child: null,
                        ),
                        const Gap(24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.localized.doYouHaveAccount,
                              style: AppTextStyles.fs14w500.copyWith(
                                  height: 1.3, color: AppColors.grey969696),
                            ),
                            const Gap(8),
                            GestureDetector(
                              onTap: () {
                                context.router.push(const LoginRoute());
                              },
                              child: Text(
                                context.localized.login,
                                style: AppTextStyles.fs14w600.copyWith(
                                    height: 1.3, color: AppColors.mainColor),
                              ),
                            ),
                          ],
                        ),
                        const Gap(24),
                        // Positioned(
                        //   bottom: 0,
                        //   left: 0,
                        //   child: IgnorePointer(
                        //     ignoring: true,
                        //     child: ReCaptchaWebView(
                        //       width: 1,
                        //       height: 1,
                        //       onTokenReceived: (token) {
                        //         // Токен сохраняется автоматически в RecaptchaHandler.instance.captchaToken
                        //       },
                        //       // Обязательно укажите URL, где лежит валидный HTML-файл с reCAPTCHA
                        //       url:
                        //           'https://emerald-eran-52.tiiny.site', // 👈 ВАЖНО!
                        //     ),
                        //   ),
                        // ),
                      ],
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

class Country {
  final String code;
  final String name;
  final String mask;
  final int digitLength;

  Country({
    required this.code,
    required this.name,
    required this.mask,
    required this.digitLength,
  });
}

List<Country> countries = [
  Country(
    code: '+7',
    name: '🇰🇿',
    mask: '(###) ###-##-##',
    digitLength: 10,
  ),
  Country(
    code: '+998',
    name: '🇺🇿',
    mask: '(##) ###-##-##',
    digitLength: 9,
  ),
];
