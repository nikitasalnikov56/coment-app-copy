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
    if (companyName != null &&
        companyName!.isNotEmpty &&
        companyName != 'null') {
      return companyName!;
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultIconColor = isDark ? Colors.white : Colors.black;
    return AppBar(
      backgroundColor: backgroundColor,
      toolbarHeight: preferredSize.height,
      leadingWidth: 57,
      leading: !btnBack
          ? Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    context.router.maybePop();
                  },
                  splashRadius: 21,
                  icon: isBackButton
                      ? SvgPicture.asset(
                          svg ?? AssetsConstants.backButton,
                          colorFilter: ColorFilter.mode(
                            svgColor ?? defaultIconColor,
                            BlendMode.srcIn,
                          ),
                        )
                      : Container(
                          width: 74,
                        ),
                ),
            ),
          )
          : null,
      centerTitle: true,
      // title: isChatPageActive
      //     ? _buildChatTitle(context)
      //     : _buildTitleColumn(context, isChatPageActive),
      flexibleSpace: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 57),
        child: isChatPageActive
            ? _buildChatTitle(context)
            : _buildTitleColumn(context, isChatPageActive),
      ),
      actions: actions,
      shape: shape,
    );
  }

  Widget _buildChatTitle(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAvatar(),
        const Gap(10),
        _buildTitleColumn(context, isChatPageActive),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      height: 60,
      width: 60,
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

  Widget _buildTitleColumn(BuildContext context, bool isChatPageActive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultSubTitleColor =
        isDark ? const Color(0xFF9E9E9E) : AppColors.greyTextColor3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        title != null
            ? SizedBox(
                height: 22,
                width: double.infinity,
                child: _buildTitleWidget(context, isChatPageActive),
              )
            : const SizedBox(),
        const Gap(2),
        subTitle != null
            ? Text(
                subTitle!,
                style: subTitleStyle ??
                    AppTextStyles.fs12w700.copyWith(
                      color: defaultSubTitleColor,
                    ),
              )
            : const SizedBox(),
      ],
    );
  }

  Widget _buildTitleWidget(BuildContext context, bool isChatPageActive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : AppColors.text;

    final String companyNamePart = companyNameData();

    final String fullText;

    if (isChatPageActive) {
      if (companyNamePart.isNotEmpty) {
        fullText = '$companyNamePart ($title)';
      } else {
        fullText = title ?? '';
      }
    } else {
      fullText = '$companyNamePart $title'.trim();
    }

    final TextStyle style =
        textStyle ?? AppTextStyles.fs16w700.copyWith(color: defaultTextColor);

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
  Size get preferredSize =>  Size.fromHeight(isChatPageActive ? 150 : kToolbarHeight);
}
