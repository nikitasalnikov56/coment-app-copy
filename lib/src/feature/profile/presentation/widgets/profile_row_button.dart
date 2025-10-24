import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import 'package:coment_app/src/core/theme/resources.dart';

class ProfileRowButton extends StatelessWidget {
  const ProfileRowButton({
    super.key,
    this.onTap,
    required this.icon,
    required this.title,
    this.titleCity,
    this.titleSecond,
  });
  final VoidCallback? onTap;
  final String icon;
  final String title;
  final String? titleSecond;
  final String? titleCity;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.muteGrey, borderRadius: BorderRadius.circular(16)),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0x33BBB5FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: SvgPicture.asset(
                    icon,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.fs16w500,
                    ),
                    Text(
                      titleSecond ?? '',
                      style: AppTextStyles.fs16w500,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
