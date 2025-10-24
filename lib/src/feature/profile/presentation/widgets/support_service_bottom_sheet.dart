import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/presentation/widgets/textfields/custom_textfield.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/profile/bloc/write_tech_support_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import 'package:coment_app/src/core/presentation/widgets/bottomsheet/custom_drag_handle.dart';
import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/theme/resources.dart';

class SupportServiceBottomSheet extends StatefulWidget {
  const SupportServiceBottomSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
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
          child: const SupportServiceBottomSheet(),
        ),
      );

  @override
  State<SupportServiceBottomSheet> createState() => _SupportServiceBottomSheetState();
}

class _SupportServiceBottomSheetState extends State<SupportServiceBottomSheet> {
  final TextEditingController textController = TextEditingController();

  bool? isLoading = false;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

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
              child: Text(context.localized.if_you_have_any_questions_or_suggestions,
                  textAlign: TextAlign.center, style: AppTextStyles.fs14w400),
            ),
            const Gap(12),
            SizedBox(
              height: 135,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomTextField(
                  controller: textController,
                  hintText: context.localized.write,
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
                  loaded: () {
                    isLoading = false;
                    setState(() {});
                    Navigator.of(context).pop();
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
                child: CustomButton(
                  onPressed: () {
                    // log(textController.text);
                    BlocProvider.of<TechSupportCubit>(context).writeTechSupport(text: textController.text);
                    setState(() {});
                  },
                  style: CustomButtonStyles.mainButtonStyle(context),
                  // style: ElevatedButton.styleFrom(
                  //   elevation: 0,
                  //   backgroundColor: AppColors.mainColor,
                  //   foregroundColor: Colors.white,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(16),
                  //   ),
                  //   padding: const EdgeInsets.symmetric(vertical: 12),
                  // ),
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
