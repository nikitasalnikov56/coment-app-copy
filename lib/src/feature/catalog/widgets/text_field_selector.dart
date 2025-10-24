import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:coment_app/src/core/theme/resources.dart';

class TextFieldSelector extends StatelessWidget {
  final String? selectedText;
  final String? hintText;
  final VoidCallback onSelectCity;

  const TextFieldSelector({
    Key? key,
    required this.selectedText,
    required this.hintText,
    required this.onSelectCity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyText),
        color: AppColors.muteGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              selectedText ?? "$hintText",
              style: selectedText != null
                  ? AppTextStyles.fs14w400.copyWith(color: Colors.black)
                  : AppTextStyles.fs14w400.copyWith(color: AppColors.greyText),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 13.0),
            child: InkWell(
              onTap: onSelectCity,
              child: SvgPicture.asset(AssetsConstants.icArrowTo),
            ),
          ),
        ],
      ),
    );
  }
}
