import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/auth/models/user_role.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  final ValueNotifier<bool> _obscureText = ValueNotifier(true);
  final ValueNotifier<String?> _passwordError = ValueNotifier(null);
  final ValueNotifier<String?> _phoneError = ValueNotifier(null);
  final ValueNotifier<String?> _surnameNameError = ValueNotifier(null);
  final ValueNotifier<String?> _userNameError = ValueNotifier(null);
  final ValueNotifier<String?> _classError = ValueNotifier(null);
  final ValueNotifier<bool> _allowTapButton = ValueNotifier(false);
  final ValueNotifier<String?> _emailError = ValueNotifier(null);
  final ValueNotifier<String?> birthDateError = ValueNotifier(null);
  CommonDTO? chosenClass;
  final String _prefix = "+";
  final FocusNode _focusNode = FocusNode();
  Country? selectedCountry;
  UserRole selectedRole = UserRole.user;

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
    usernameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    _surnameNameError.dispose();
    _userNameError.dispose();
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
          errorLabel: context.localized.incorrectLogin,
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
                     Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Text(
                        context.localized.birthDate,
                        style: AppTextStyles.fs16w600
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        context.localized.cancel,
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
                     context.localized.confirm,
                      style: AppTextStyles.fs16w400
                          .copyWith(color: AppColors.kF5F6F7),
                    ),
                    onPressed: () {
                      birthDateController.text =
                          tempDate.toIso8601String().split('T')[0];
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
// 1. Обнуляем старые ошибки
              _emailError.value = null;
              _phoneError.value = null;
              _userNameError.value = null;

              final msg = message.toLowerCase();
              // Проверка по тексту (на всякий случай, если структура ответа изменится)
              if (msg.contains('email')) {
                _emailError.value = context.localized.emailAlreadyRegistered;
              }

              if (msg.contains('phone')) {
                _phoneError.value = context.localized.phoneAlreadyTaken;
              }
              if (msg.contains('username')) {
                _userNameError.value = context.localized.usernameAlreadyTaken;
              }
              // 3. ПРИНУДИТЕЛЬНАЯ ВАЛИДАЦИЯ
              // Это тот самый «пинок», который заставит поля перекраситься в красный
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_formKey.currentState != null) {
                  _formKey.currentState!.validate();
                }
              });

              // Если ошибок в полях нет, но ошибка пришла — покажем тост
              if (_emailError.value == null &&
                  _phoneError.value == null &&
                  _userNameError.value == null) {
                Toaster.showErrorTopShortToast(context, message);
              }
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
              Toaster.showTopShortToast(context, message: context.localized.success);
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
              body: SafeArea(
                child: Form(
                  key: _formKey,
                  // autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: SingleChildScrollView(
                    physics:const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.localized.accountRegister, //accountRegister
                            style: AppTextStyles.fs26w700.copyWith(height: 1.25),
                          ),
                          const Gap(4),
                          Text(
                            context.localized.joinInSecond, //joinInSecond
                            style: AppTextStyles.fs16w500.copyWith(height: 1.7),
                          ),
                          const Gap(12),
                          Text(
                            context
                                .localized.enterYourFullName, //enterYourFullName
                            style: AppTextStyles.fs14w500.copyWith(height: 1.3),
                          ),
                          const Gap(6),
                          CustomValidatorTextfield(
                            controller: surnameNameController,
                            valueListenable: _surnameNameError,
                            hintText: context.localized.fullname, //fulname
                            onChanged: (value) {
                              checkAllowTapButton();
                            },
                            validator: (String? value) {
                              return null;
                            },
                          ),
                           const Gap(12),
                          Text(
                            context.localized.enterYourUsername,
                            style: AppTextStyles.fs14w500.copyWith(height: 1.3),
                          ),
                          const Gap(6),
                          CustomValidatorTextfield(
                            controller: usernameController,
                            valueListenable: _userNameError,
                            hintText: context.localized.enterYourUsername, //fulname
                            onChanged: (value) {
                              // Сбрасываем ошибку сервера при начале ввода новых данных
                              if (_userNameError.value != null) {
                                _userNameError.value = null;
                              }
                              checkAllowTapButton();
                            },
                            validator: (String? value) {
                              if (value == null || value.trim().isEmpty) {
                                return context.localized.usernameRequired;
                              }
                              return _userNameError.value;
                            },
                          ),
                          const Gap(12),
                          Text(
                            context.localized
                                .enterYourEmailAddress, // enterYourEmailAddress
                            style: AppTextStyles.fs14w500.copyWith(height: 1.3),
                          ),
                          const Gap(6),
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
                            },
                          ),
                          const Gap(12),
                          Text(
                            context.localized.enterYourBirthDate,
                            style: AppTextStyles.fs14w500.copyWith(height: 1.3),
                          ),
                          const Gap(6),
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
                          const Gap(12),
                          Text(
                            context.localized.enterYourPhoneNumber,
                            style: AppTextStyles.fs14w500.copyWith(height: 1.3),
                          ),
                
                          const Gap(6),
                          CustomValidatorTextfield(
                            controller: phoneController,
                            valueListenable:
                                _phoneError, // Убедитесь, что это именно этот нотификатор
                            hintText: selectedCountry!.mask.replaceAll('#', '_'),
                            keyboardType: TextInputType.phone,
                            prefixIconWidget: Padding(
                              padding: const EdgeInsets.only(left: 18.0),
                              child: DropdownButton<Country>(
                                value: selectedCountry,
                                underline: const SizedBox(),
                                items: countries
                                    .map((country) => DropdownMenuItem(
                                          value: country,
                                          child: Text(
                                              '${country.name} ${country.code}'),
                                        ))
                                    .toList(),
                                onChanged: (Country? newCountry) {
                                  if (newCountry != null) {
                                    setState(() {
                                      selectedCountry = newCountry;
                                      phoneController.clear();
                                      _phoneError.value =
                                          null; // Сбрасываем ошибку при смене страны
                                    });
                                  }
                                },
                              ),
                            ),
                            inputFormatters: [
                              MaskTextInputFormatter(
                                mask: selectedCountry!.mask,
                                filter: {"#": RegExp(r'[0-9]')},
                              ),
                            ],
                            onChanged: (value) {
                              if (_phoneError.value != null) {
                                _phoneError.value =
                                    null; // Убираем ошибку при вводе
                              }
                              checkAllowTapButton();
                            },
                            validator: (value) => _phoneError
                                .value, // Привязываем валидатор к нотификатору
                          ),
                
                          const Gap(12),
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
                          const Gap(12),
                          Text(
                            context.localized.userRole,
                            style: AppTextStyles.fs14w500.copyWith(height: 1.3),
                          ),
                          const Gap(6),
                          SizedBox(
                            width: double.infinity,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.borderTextField,
                                  ),
                                  borderRadius: BorderRadius.circular(12)),
                              child: DropdownButton<UserRole>(
                                alignment: Alignment.center,
                                isExpanded: true,
                                padding:
                                    const EdgeInsets.only(right: 12, left: 16),
                                underline: const SizedBox(),
                                menuWidth:
                                    MediaQuery.of(context).size.width / 0.8,
                                items: [
                                  DropdownMenuItem(
                                    value: UserRole.user,
                                    child: Text(context.localized.user,
                                        style: AppTextStyles.fs14w500
                                            .copyWith(height: 1.3)),
                                  ),
                                  DropdownMenuItem(
                                    value: UserRole.owner,
                                    child: Text(context.localized.owner,
                                        style: AppTextStyles.fs14w500
                                            .copyWith(height: 1.3)),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedRole = value ?? UserRole.user;
                                  });
                                },
                                value: selectedRole,
                              ),
                            ),
                          ),
                
                          const Gap(20),
                          CustomButton(
                            allowTapButton: _allowTapButton,
                            onPressed: () {
                              if (!_formKey.currentState!.validate()) return;
                              String nationalNumber = phoneController.text
                                  .replaceAll(RegExp(r'[^0-9]'), '');
                              String fullPhoneNumber =
                                  selectedCountry!.code + nationalNumber;
                              fullPhoneNumber = fullPhoneNumber.trim();
                              BlocProvider.of<RegisterCubit>(context).register(
                                email: emailController.text,
                                name: surnameNameController.text,
                                username: usernameController.text,
                                password: passwordController.text,
                                phone: fullPhoneNumber,
                                deviceType:
                                    Platform.isAndroid ? 'Android' : 'IOS',
                                birthDate: birthDateController.text,
                                role: selectedRole.name,
                              );
                            },
                            style: CustomButtonStyles.mainButtonStyle(context),
                            text: context.localized.signUp,
                            child: null,
                          ),
                          const Gap(16),
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
  Country(
    code: '+7',
    name: '🇷🇺',
    mask: '(###) ###-##-##',
    digitLength: 10,
  ),
  Country(
    code: '+86',
    name: '🇨🇳',
    mask: '### #### ####',
    digitLength: 11,
  ),
];
