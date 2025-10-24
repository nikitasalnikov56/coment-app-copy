import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import 'package:coment_app/src/core/presentation/widgets/bottomsheet/custom_drag_handle.dart';
import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/theme/resources.dart';

class OpinionBs extends StatelessWidget {
  const OpinionBs({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (context) => const OpinionBs(),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomDragHandle(),
          const Gap(13),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Поделитесь вашим мнением',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.fs18w700,
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        decoration: BoxDecoration(color: AppColors.kF5F6F7, borderRadius: BorderRadius.circular(16)),
                        alignment: Alignment.center,
                        height: 26,
                        width: 26,
                        child: SvgPicture.asset(AssetsConstants.notX),
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                const Text('Опишите, что не так с отзывом, чтобы мы могли быстрее с ним разобраться',
                    style: AppTextStyles.fs14w400),
                const Gap(12),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Напишите ...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  maxLines: 4,
                ),
                const Gap(32),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // RequestSentBottomSheet.show(context);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.mainColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Отправить',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
        ],
      ),
    );
  }
}
