// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/constant/constants.dart';
import 'package:coment_app/src/core/presentation/widgets/textfields/custom_textfield.dart';
import 'package:coment_app/src/feature/app/bloc/app_bloc.dart';
import 'package:coment_app/src/feature/auth/presentation/pages/register_page.dart';
import 'package:coment_app/src/feature/profile/bloc/profile_bloc.dart';
import 'package:coment_app/src/feature/profile/bloc/profile_edit_cubit.dart';
import 'package:coment_app/src/feature/profile/presentation/widgets/logout_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/presentation/widgets/dialog/toaster.dart';
import 'package:coment_app/src/core/presentation/widgets/other/custom_loading_overlay_widget.dart';
import 'package:coment_app/src/core/presentation/widgets/textfields/custom_validator_textfield.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/core/utils/input/validator_util.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
import 'package:coment_app/src/feature/auth/models/user_dto.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

@RoutePage()
class EditProfilePage extends StatefulWidget implements AutoRouteWrapper {
  const EditProfilePage({super.key, this.user});
  final UserDTO? user;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProfileEditCubit(
            repository: context.repository.profileRepository,
          ),
        ),
      ],
      child: this,
    );
  }
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController surnameController =
      TextEditingController(text: 'Mark');
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  final ValueNotifier<String?> _surnameError = ValueNotifier(null);
  final ValueNotifier<String?> _phoneError = ValueNotifier(null);
  final ValueNotifier<String?> _passwordError = ValueNotifier(null);
  final ValueNotifier<String?> _emailError = ValueNotifier(null);
  final ValueNotifier<bool> _allowTapButton = ValueNotifier(false);
  final ValueNotifier<bool> _obscureText = ValueNotifier(true);
  final ValueNotifier<String?> birthDateError = ValueNotifier(null);

  String imageNetwork = '';
  XFile? image;

  final FocusNode passwordFocus = FocusNode();

  Country? selectedCountry;
  String? phoneNumber;
  MaskTextInputFormatter maskPhoneFormatter = MaskTextInputFormatter(
    mask: '+#(###) ###-##-##',
    filter: {"#": RegExp('[0-9]')},
  );

  @override
  void dispose() {
    surnameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    _surnameError.dispose();
    _emailError.dispose();
    _passwordError.dispose();
    _phoneError.dispose();
    _allowTapButton.dispose();
    passwordFocus.dispose();
    birthDateController.dispose();
    birthDateError.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    final phone = widget.user?.phone;
    if (phone != null) {
      parsePhoneNumber(phone);
    } else {
      selectedCountry = countries.first;
      phoneController.text = '';
    }

    surnameController.text = widget.user?.name ?? '';
    emailController.text = widget.user?.email ?? '';
    imageNetwork = widget.user?.avatar ?? '';
    checkAllowTapButton();
  }

  void parsePhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith("+7")) {
      selectedCountry = countries.firstWhere((c) => c.code == "+7");

      phoneController.text = phoneNumber
          .substring(2)
          .replaceAll(RegExp(r'[^0-9]'), ''); // Убираем "+7"
    } else if (phoneNumber.startsWith("+998")) {
      selectedCountry = countries.firstWhere((c) => c.code == "+998");
      phoneController.text = phoneNumber
          .substring(4)
          .replaceAll(RegExp(r'[^0-9]'), ''); // Убираем "+998"
    } else {
      selectedCountry = countries.first;
      phoneController.text = phoneNumber.replaceAll(
          RegExp(r'[^0-9]'), ''); // Записываем весь номер
    }
  }

  bool checkAllowTapButton() {
    final isEmailValid = ValidatorUtil.emailValidator(
          emailController.text,
          errorLabel: 'Неверный логин',
        ) ==
        null;
    final isPasswordValid =
        passwordController.text.length >= 6 || passwordController.text == '';
    String phoneUnmasked =
        phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    bool isPhoneValid = phoneUnmasked.length == selectedCountry?.digitLength;

    return _allowTapButton.value = surnameController.text.isNotEmpty &&
        isEmailValid &&
        isPhoneValid &&
        isPasswordValid;
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
                      birthDateController.text =
                          tempDate.toIso8601String().split('T')[0];
                                          if (context.mounted) {
                        setState(() {});
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
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return LoaderOverlay(
      overlayWidgetBuilder: (progress) => const CustomLoadingOverlayWidget(),
      overlayColor: AppColors.barrierColor,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: CustomAppBar(
            title: context.localized.editProfile,
            actions: [
              Container(
                width: 40,
              )
            ],
          ),
          // appBar: CustomAppBar(
          //   quarterTurns: 0,
          //   title: context.localized.editProfile,
          //   shape: const Border(),
          // ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              // autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: keyboardHeight),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ///
                            /// edit avatar
                            ///
                            const Gap(17),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  showCupertinoModalPopup(
                                    context: context,
                                    builder: (context) {
                                      return CupertinoActionSheet(
                                        actions: [
                                          CupertinoActionSheetAction(
                                            onPressed: () =>
                                                pickImageFromGallery(
                                              ImageSource.camera,
                                            ).whenComplete(() {
                                              if (context.mounted) {
                                                context.router.maybePop();
                                              }
                                              setState(() {});
                                            }),
                                            child: Text(
                                              context.localized.camera,
                                              style: AppTextStyles.fs16w400
                                                  .copyWith(
                                                      color: Colors.black),
                                            ),
                                          ),
                                          CupertinoActionSheetAction(
                                            onPressed: () =>
                                                pickImageFromGallery(
                                              ImageSource.gallery,
                                            ).whenComplete(() {
                                              if (context.mounted) {
                                                context.router.maybePop();
                                              }
                                              setState(() {});
                                            }),
                                            child: Text(
                                              context.localized.gallery,
                                              style: AppTextStyles.fs16w400
                                                  .copyWith(
                                                      color: Colors.black),
                                            ),
                                          ),
                                        ],
                                        cancelButton:
                                            CupertinoActionSheetAction(
                                          onPressed: () {
                                            context.router.maybePop();
                                          },
                                          child: Text(
                                            context.localized.cancel,
                                            style: AppTextStyles.fs16w400
                                                .copyWith(color: Colors.red),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: SizedBox(
                                  height: 110,
                                  width: 110,
                                  child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: [
                                      Container(
                                        height: 110,
                                        width: 110,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: AppColors.mainColor,
                                              width: 3),

                                          // boxShadow: [
                                          //   BoxShadow(
                                          //     color: Colors.black.withOpacity(0.1),
                                          //     blurRadius: 5.6,
                                          //   ),
                                          // ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6.6),
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100)),
                                            child: image != null
                                                ? Image.file(
                                                    File(image?.path ?? ''),
                                                    fit: BoxFit.cover,
                                                  )
                                                : imageNetwork.isNotEmpty
                                                    ? Image.network(
                                                        imageNetwork,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Stack(
                                                        children: [
                                                          Container(
                                                            // color: Colors.white,
                                                            decoration:
                                                                const BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child:
                                                                Image.network(
                                                              NOT_FOUND_IMAGE,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          Container(
                                                            // margin: const EdgeInsets.all(10),
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.4),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(38.65),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(100)),
                                          ),
                                          child: Center(
                                              child: SvgPicture.asset(
                                                  AssetsConstants.icCamera)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Gap(18),

                            Text(
                              context.localized.enterYourFullName,
                              style: AppTextStyles.fs14w400
                                  .copyWith(color: AppColors.text),
                            ),
                            const Gap(8),

                            ///
                            /// edit surname
                            ///
                            CustomValidatorTextfield(
                              controller: surnameController,
                              valueListenable: _surnameError,
                              hintText: context.localized.enterYourFullName,
                              onChanged: (value) {
                                checkAllowTapButton();
                              },
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return _surnameError.value =
                                      context.localized.required_to_fill;
                                }

                                return _surnameError.value = null;
                              },
                            ),
                            const Gap(16),
                            Text(
                              context.localized.enterYourEmailAddress,
                              style: AppTextStyles.fs14w400
                                  .copyWith(color: AppColors.text),
                            ),
                            const Gap(8),

                            ///
                            /// edit email
                            ///
                            CustomValidatorTextfield(
                              controller: emailController,
                              valueListenable: _emailError,
                              hintText: context.localized.enterYourEmailAddress,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (value) {
                                checkAllowTapButton();
                              },
                              validator: (String? value) {
                                return _emailError.value =
                                    ValidatorUtil.emailValidator(
                                  emailController.text,
                                  errorLabel: '',
                                );
                              },
                            ),
                            const Gap(16),

                            ///
                            /// edit date of birth
                            ///
                            Text(
                              context.localized.enterYourBirthDate,
                              style:
                                  AppTextStyles.fs14w500.copyWith(height: 1.3),
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

                            ///
                            /// edit phone number
                            ///
                            Text(
                              context.localized.enterYourPhoneNumber,
                              style: AppTextStyles.fs14w400,
                            ),
                            const Gap(8),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    key:
                                        Key(selectedCountry?.code ?? 'default'),
                                    height: 44,
                                    obscureText: false,
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          width: 1,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color: AppColors.borderTextField),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    prefixIconWidget: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 18.0),
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
                                        mask: selectedCountry?.mask,
                                        filter: {"#": RegExp(r'[0-9]')},
                                      ),
                                    ],
                                    keyboardType: TextInputType.phone,
                                    hintText: selectedCountry?.mask
                                        .replaceAll('#', '_'),
                                    onChanged: (value) {
                                      checkAllowTapButton();
                                    },
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return _phoneError.value =
                                            context.localized.required_to_fill;
                                      }
                                      String unmasked = value.replaceAll(
                                          RegExp(r'[^0-9]'), '');
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
                              style: AppTextStyles.fs14w400
                                  .copyWith(color: AppColors.text),
                            ),
                            const Gap(8),

                            ///
                            /// password
                            ///
                            ValueListenableBuilder(
                              valueListenable: _obscureText,
                              builder: (context, v, c) {
                                return CustomValidatorTextfield(
                                  focusNode: passwordFocus,
                                  obscureText: _obscureText,
                                  controller: passwordController,
                                  valueListenable: _passwordError,
                                  hintText: context.localized.enterThePassword,
                                  onChanged: (value) {
                                    checkAllowTapButton();
                                  },
                                );
                              },
                            ),
                            const Gap(100),

                            ///
                            /// save button
                            ///
                            BlocListener<ProfileEditCubit, ProfileEditState>(
                              listener: (context, state) {
                                state.maybeWhen(
                                  error: (message) {
                                    context.loaderOverlay.hide();
                                    Toaster.showErrorTopShortToast(
                                        context, message);
                                    //
                                  },
                                  loading: () {
                                    context.loaderOverlay.show();
                                  },
                                  loaded: () {
                                    context.loaderOverlay.hide();
                                    context.router.popUntil((route) =>
                                        route.settings.name ==
                                        LauncherRoute.name);
                                    BlocProvider.of<ProfileBLoC>(context)
                                        .add(const ProfileEvent.getProfile());
                                  },
                                  orElse: () {
                                    context.loaderOverlay.hide();
                                  },
                                );
                              },
                              child: CustomButton(
                                allowTapButton: _allowTapButton,
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    log('$image', name: 'image');
                                    log(surnameController.text, name: 'name');
                                    log(emailController.text, name: 'email');
                                    log("${selectedCountry?.code ?? ''}${phoneController.text}",
                                        name: 'phone');
                                    log(passwordController.text,
                                        name: 'password');

                                    BlocProvider.of<ProfileEditCubit>(context)
                                        .editAccount(
                                      password: passwordController.text,
                                      name: surnameController.text,
                                      email: emailController.text,
                                      avatar: image,
                                      phone:
                                          "${selectedCountry?.code ?? ''}${phoneController.text}",
                                      birthDate: birthDateController.text,

                                      /// зменить на реальный выбор даты
                                      cityId: -1,
                                      languageId: -1,
                                    );
                                  }
                                },
                                style: null,
                                text: context.localized.save,
                                child: null,
                              ),
                            ),
                            const Gap(12),

                            ///
                            /// delete account
                            ///
                            BlocListener<ProfileBLoC, ProfileState>(
                              listener: (context, state) {
                                state.maybeWhen(
                                  error: (message) {
                                    context.loaderOverlay.hide();
                                    Toaster.showErrorTopShortToast(
                                        context, message);
                                  },
                                  loading: () {
                                    context.loaderOverlay.show();
                                  },
                                  orElse: () {
                                    context.loaderOverlay.hide();
                                  },
                                  exited: (message) {
                                    context.loaderOverlay.hide();
                                    Toaster.showTopShortToast(context,
                                        message: message);
                                    context.router.popUntil((route) =>
                                        route.settings.name ==
                                        LauncherRoute.name);
                                    BlocProvider.of<AppBloc>(context)
                                        .add(const AppEvent.exiting());
                                  },
                                );
                              },
                              child: GestureDetector(
                                onTap: () {
                                  if (passwordController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          context.localized.enterThePassword,
                                          style: AppTextStyles.fs14w400,
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  LogoutBottomSheet.show(
                                    context,
                                    isDeleteAccount: true,
                                    onPressed: () {
                                      BlocProvider.of<ProfileBLoC>(context)
                                          .add(ProfileEvent.deleteAccount(
                                        password:
                                            passwordController.text.trim(),
                                      ));
                                      Navigator.pop(context);
                                    },
                                  ).whenComplete(() {
                                    FocusScope.of(context).unfocus();
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   const SnackBar(
                                    //     content: Text(
                                    //       'Ваш аккаунт успешно удалён. У вас есть 30 дней для восстановления.',
                                    //     ),
                                    //   ),
                                    // );
                                  });
                                },
                                child: Center(
                                  child: Text(
                                    context.localized.delete_an_account,
                                    style: AppTextStyles.fs16w500
                                        .copyWith(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            const Gap(16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future pickImageFromGallery(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imageTemporary = XFile(image.path);
      setState(() {
        this.image = imageTemporary;
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }
}
