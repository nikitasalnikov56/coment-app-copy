import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class TranslateReplyWidget extends StatelessWidget {
  const TranslateReplyWidget({super.key, required this.replyComment});
  final String? replyComment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: () {
          print(context.currentLocale);
          print(replyComment);
        },
        child: Text(
          context.localized.translateComment,
          style: AppTextStyles.fs14w600.copyWith(color: AppColors.blue43),
        ),
      ),
    );
  }
}
