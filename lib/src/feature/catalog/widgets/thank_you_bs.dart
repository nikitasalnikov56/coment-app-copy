import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/presentation/widgets/bottomsheet/custom_drag_handle.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class ThankYouBs extends StatelessWidget {
  const ThankYouBs({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (context) => const ThankYouBs(),
      );

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomDragHandle(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 350),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(color: AppColors.kF5F6F7, borderRadius: BorderRadius.circular(16)),
                      alignment: Alignment.center,
                      height: 26,
                      width: 26,
                      child: SvgPicture.asset(AssetsConstants.notX),
                    ),
                  ),
                ),
                const Gap(22),
                const Icon(
                  Icons.check_circle,
                  size: 53.33,
                  color: AppColors.mainColor,
                ),
                const Gap(16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Спасибо за обращение, вы делаете мир лучше',
                      textAlign: TextAlign.center, style: AppTextStyles.fs22w700),
                ),
                const Gap(22),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
