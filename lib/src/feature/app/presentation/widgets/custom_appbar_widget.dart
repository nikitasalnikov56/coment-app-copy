import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/constant/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:gap/gap.dart';
import 'package:marquee/marquee.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subTitle;
  final String? companyName;

  final String? svg;
  final Color? color;
  final Color? backgroundColor;
  final Color? svgColor;
  final int? quarterTurns;
  final List<Widget>? actions;
  final void Function()? onPressed;
  final bool? onBack;
  final ShapeBorder? shape;
  final TextStyle? textStyle;
  final TextStyle? companyStyle;
  final bool isBackButton;
  final bool isOnline;
  final TextStyle? subTitleStyle;
  final bool btnBack;
  final bool isChatPageActive;
  // final String? avatarUrl;
  final String? decorationImageUrl;

  final Widget? titleWidget;

  const CustomAppBar({
    super.key,
    this.title,
    this.companyName,
    this.subTitle,
    this.actions,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.svgColor,
    this.svg,
    this.quarterTurns,
    this.shape,
    this.textStyle,
    this.companyStyle,
    this.subTitleStyle,
    this.isBackButton = true,
    this.isOnline = false,
    this.btnBack = false,
    this.onBack = false,
    this.isChatPageActive = false,
    this.titleWidget,
    // this.avatarUrl = '',
    this.decorationImageUrl,
  });

  String companyNameData() {
    if (companyName != null) {
      return '$companyName';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      leadingWidth: 57,
      leading: !btnBack
          ? IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                context.router.maybePop();
              },
              splashRadius: 21,
              icon: isBackButton
                  ? SvgPicture.asset(
                      svg ?? AssetsConstants.backButton,
                      colorFilter: ColorFilter.mode(
                        svgColor ?? Colors.black,
                        BlendMode.srcIn,
                      ),
                    )
                  : Container(
                      width: 74,
                    ),
            )
          : null,
      centerTitle: true,
      title: isChatPageActive
          ? _buildChatTitle()
          : _buildTitleColumn(isChatPageActive),
      actions: actions,
      shape: shape,
    );
  }

  Widget _buildChatTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAvatar(),
        const Gap(15),
        Flexible(
          child: _buildTitleColumn(isChatPageActive),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF7573F3), width: 3),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(decorationImageUrl ?? NOT_FOUND_IMAGE),
        ),
      ),
    );
  }

  Widget _buildTitleColumn(bool isChatPageActive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        title != null
            ? SizedBox(
                height: 22, // Задай фиксированную высоту для Marquee
                width: double.infinity,
                child: _buildTitleWidget(isChatPageActive),
              )
            : const SizedBox(),
        const Gap(2),
        const Gap(2),
        subTitle != null
            ? Text(subTitle!, style: subTitleStyle)
            : const SizedBox(),
      ],
    );
  }

  Widget _buildTitleWidget(bool isChatPageActive) {
    final String fullText =
        '${companyNameData()} ${isChatPageActive ? '($title)' : '$title'}';
    final TextStyle style =
        textStyle ?? AppTextStyles.fs16w700.copyWith(color: AppColors.text);

    return LayoutBuilder(
      builder: (context, constraints) {
        // 1. Измеряем ширину текста при заданном стиле
        final textPainter = TextPainter(
          text: TextSpan(text: fullText, style: style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();

        // 2. Сравниваем ширину текста с шириной экрана (минус отступы для кнопок)
        // constraints.maxWidth обычно дает доступную ширину заголовка в AppBar
        final bool isOverflowing = textPainter.width > constraints.maxWidth;

        if (isOverflowing) {
          // ТЕКСТ НЕ ВЛЕЗАЕТ — включаем бегущую строку
          return Marquee(
            text: fullText,
            style: style,
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            blankSpace: 80.0,
            velocity: 35.0,
            pauseAfterRound: const Duration(days: 5),
            startAfter: const Duration(seconds: 2),
            startPadding: 0.0,
            accelerationDuration: const Duration(seconds: 1),
            decelerationDuration: const Duration(seconds: 1),
          );
        } else {
          // ТЕКСТ ВЛЕЗАЕТ — показываем просто текст по центру
          return Center(
            child: Text(
              fullText,
              style: style,
              maxLines: 1,
            ),
          );
        }
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
