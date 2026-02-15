import 'package:coment_app/src/core/theme/resources.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateChip extends StatelessWidget {
  const DateChip({super.key, required this.date});

  final DateTime date;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Divider(
            color: AppColors.borderColor,
            thickness: 2,
            indent: 15,
            endIndent: 10,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[400]?.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                DateFormat('d MMMM').format(date),
                style: AppTextStyles.fs12w500.copyWith(
                  color: AppColors.black,
                ),
              ),
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: AppColors.borderColor,
            thickness: 2,
            indent: 10,
            endIndent: 15,
          ),
        ),
      ],
    );
  }
}
