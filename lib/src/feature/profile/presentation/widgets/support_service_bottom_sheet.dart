import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/presentation/widgets/textfields/custom_textfield.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/auth/models/user_dto.dart';

import 'package:coment_app/src/feature/profile/bloc/write_tech_support_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import 'package:coment_app/src/core/presentation/widgets/bottomsheet/custom_drag_handle.dart';
import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/theme/resources.dart';

class SupportServiceBottomSheet extends StatefulWidget {
  const SupportServiceBottomSheet({super.key, required this.user});
  final UserDTO? user;

  static Future<void> show(BuildContext context, {required UserDTO user}) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: true,
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => TechSupportCubit(
                repository: context.repository.profileRepository,
              ),
            ),
          ],
          child: SupportServiceBottomSheet(
            user: user,
          ),
        ),
      );

  @override
  State<SupportServiceBottomSheet> createState() =>
      _SupportServiceBottomSheetState();
}

class _SupportServiceBottomSheetState extends State<SupportServiceBottomSheet> {
  final TextEditingController textController = TextEditingController();
  final TextEditingController themeController = TextEditingController();
  final TextEditingController emailTextController = TextEditingController();

  bool? isLoading = false;

  @override
  void dispose() {
    textController.dispose();
    themeController.dispose();
    emailTextController.dispose();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    emailTextController.text = widget.user?.email ?? '';
  }

  String? selectedCategory;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(child: CustomDragHandle()),

            ///
            /// <-- `title and closing icon` -->
            ///
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    context.localized.support_service,
                    style: AppTextStyles.fs18w700.copyWith(height: 1.35),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: SvgPicture.asset(
                      AssetsConstants.close,
                      height: 26,
                    ),
                  ),
                ),
              ],
            ),
            // const Gap(8),
            Image.asset(
              AssetsConstants.supportServiceBS,
              height: 120,
              width: 120,
            ),
            const Gap(12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                  context.localized.if_you_have_any_questions_or_suggestions,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.fs14w400),
            ),
            const Gap(12),
            SizedBox(
              height: 40,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomTextField(
                  controller: themeController,
                  hintText: context.localized.writeTheme,
                  contentPadding: const EdgeInsets.only(left: 15, top: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  maxLines: 4,
                ),
              ),
            ),
            const Gap(12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
                value: selectedCategory,
                hint: Text(
                  context.localized.selectSupportCategory,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.fs14w400,
                ),
                items: [
                  context.localized.technicalIssues,
                  context.localized.accountProblems,
                  context.localized.paymentsAndBilling,
                  context.localized.featureRequest,
                  context.localized.reportBug,
                  context.localized.otherCategory,
                ]
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          item,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.fs14w400,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedCategory = val;
                  });
                },
              ),
            ),
            const Gap(12),
            SizedBox(
              height: 135,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomTextField(
                  controller: textController,
                  hintText: context.localized.write,
                  maxLength: 5000,
                  showMaxLengthLabel: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  maxLines: 4,
                ),
              ),
            ),
            const Gap(12),
            SizedBox(
              height: 40,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomTextField(
                  controller: emailTextController,
                  hintText: context.localized.enterYourEmailAddress,
                  contentPadding: const EdgeInsets.only(left: 15, top: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  maxLines: 4,
                ),
              ),
            ),
            BlocListener<TechSupportCubit, TechSupportState>(
              listener: (context, state) {
                state.maybeWhen(
                  orElse: () {
                    isLoading = false;
                    setState(() {});
                  },
                  loading: () {
                    isLoading = true;
                  },
                  loaded: (String message) {
                    isLoading = false;
                    setState(() {});
                    Navigator.of(context).pop();
                    // После небольшой задержки (чтобы bottom sheet успел закрыться)
                    Future.delayed(Duration.zero, () {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      }
                    });
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
                child: CustomButton(
                  onPressed: () {
                    final subject = themeController.text.trim();
                    final message = textController.text.trim();
                    final contactEmail = emailTextController.text.trim();
                    final category = selectedCategory;

                    if (subject.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(context.localized.subjectIsRequired)));
                      return;
                    }
                    if (subject.length > 200) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(context.localized.subjectTooLong)));
                      return;
                    }

                    if (message.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(context.localized.messageIsRequired)));
                      return;
                    }
                    if (message.length > 5000) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(context.localized.messageTooLong)),
                      );
                      return;
                    }
                    if (category == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(context.localized.categoryIsRequired)));
                      return;
                    }

                    // 4. Проверяем email
                    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (contactEmail.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(context.localized.emailIsRequired)),
                      );
                      return;
                    }
                    if (!emailRegExp.hasMatch(contactEmail)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.localized.invalidEmail)),
                      );
                      return;
                    }
                    // 5. Маппинг категории из локализованного текста в enum-значение
                    String? categoryValue;
                    switch (category) {
                      case final v when v == context.localized.technicalIssues:
                        categoryValue = 'technical';
                      case final v when v == context.localized.accountProblems:
                        categoryValue = 'account';
                      case final v
                          when v == context.localized.paymentsAndBilling:
                        categoryValue = 'payment';
                      case final v when v == context.localized.featureRequest:
                        categoryValue = 'feature_request';
                      case final v when v == context.localized.reportBug:
                        categoryValue = 'bug_report';
                      case final v when v == context.localized.otherCategory:
                        categoryValue = 'other';
                      default:
                        categoryValue = 'other';
                    }

                    BlocProvider.of<TechSupportCubit>(context).writeTechSupport(
                      subject: subject,
                      message: message,
                      category: categoryValue,
                      contactEmail: contactEmail,
                    );
                    setState(() {});
                  },
                  style: CustomButtonStyles.mainButtonStyle(context),
                  child: isLoading == true
                      ? const CircularProgressIndicator.adaptive()
                      : Text(
                          context.localized.send,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
            const Gap(30),
          ],
        ),
      ),
    );
  }
}
