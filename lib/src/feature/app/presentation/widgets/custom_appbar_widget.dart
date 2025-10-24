import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:coment_app/src/core/theme/resources.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  final String? svg;
  final Color? color;
  final int? quarterTurns;
  final List<Widget>? actions;
  final void Function()? onPressed;
  final ShapeBorder? shape;
  final TextStyle? textStyle;
  final bool isBackButton;
  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.onPressed,
    this.color,
    this.svg,
    this.quarterTurns,
    this.shape,
    this.textStyle,
    this.isBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 57,
      leading: IconButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          context.router.maybePop();
        },
        splashRadius: 21,
        icon: isBackButton
            ? SvgPicture.asset(svg ?? AssetsConstants.backButton)
            : Container(
                width: 74,
              ),
      ),
      centerTitle: true,
      title: title != null
          ? Text(title!, style: textStyle ?? AppTextStyles.fs16w700.copyWith(color: AppColors.text))
          : const SizedBox(),
      actions: actions,
      shape: shape,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
