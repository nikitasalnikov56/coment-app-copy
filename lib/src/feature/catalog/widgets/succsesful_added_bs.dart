
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/presentation/widgets/bottomsheet/custom_drag_handle.dart';
import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class SuccsesfulAddedBs extends StatelessWidget {
  const SuccsesfulAddedBs({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (context) => const SuccsesfulAddedBs(),
      );

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
        padding: EdgeInsets.only(bottom: padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Align(child: CustomDragHandle()),

            ///
            /// title and closing icon
            ///
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    onPressed: () {
                      // context.router.popUntil((route) => route.settings.name == AddFeedbackSearchingRoute.name);
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
            const Gap(10),
            const Icon(
              Icons.check_circle,
              size: 53.33,
              color: AppColors.mainColor,
            ),
            const Gap(16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Ваш отзыв успешно добавлен, вы делаете мир лучше',
                  textAlign: TextAlign.center, style: AppTextStyles.fs22w700),
            ),

            ///
            /// button
            ///
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
              child: CustomButton(
                onPressed: () {
                  // context.router.popUntil((route) => route.settings.name == AddFeedbackSearchingRoute.name);
                  Navigator.of(context).pop();
                },
                style: CustomButtonStyles.mainButtonStyle(context),
                child: const Text('Готово', style: AppTextStyles.fs16w600),
              ),
            ),
            const Gap(30),
          ],
        ));
  }
}
