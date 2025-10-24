import 'package:coment_app/src/core/theme/resources.dart';
import 'package:flutter/material.dart';

class FilterWrapItem extends StatelessWidget {
  final String title;
  final bool selected;
  final void Function() onTap;

  const FilterWrapItem({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10, bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.grey2,
        border: Border.all(color: selected ? AppColors.mainColor : AppColors.grey2, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: AppTextStyles.fs14w400.copyWith(height: 1.2),
            ),
          ),
        ),
      ),
    );
  }
}
