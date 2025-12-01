import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class TranslateFeedpackWidget extends StatelessWidget {
  const TranslateFeedpackWidget({super.key, required this.feedbackComment});
  final String? feedbackComment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: () {
          print(context.currentLocale);
          print(feedbackComment);
        },
        child: Text(
          context.localized.translateComment,
          style: AppTextStyles.fs14w600.copyWith(color: AppColors.blue43),
        ),
      ),
    );
  }
}
