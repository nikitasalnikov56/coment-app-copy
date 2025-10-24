import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:coment_app/src/core/theme/resources.dart';

class PasswordEyeSuffixIcon extends StatelessWidget {
  const PasswordEyeSuffixIcon({
    super.key,
    required this.valueListenable,
    this.hasError = true,
  });
  final ValueNotifier<bool> valueListenable;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        valueListenable.value = !valueListenable.value;
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 16, left: 10),
        child: SvgPicture.asset(
          height: 18,
          valueListenable.value ? AssetsConstants.visibility :AssetsConstants.visibilityOff,
          colorFilter: hasError ? const ColorFilter.mode(AppColors.red, BlendMode.srcIn) : null,
        ),
      ),
    );
  }
}
