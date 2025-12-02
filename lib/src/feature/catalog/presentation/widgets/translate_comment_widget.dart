import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/catalog/bloc/translate_comment_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



enum TranslateType { feedback, reply }

class TranslateCommentWidget extends StatelessWidget {
  const TranslateCommentWidget({
    super.key,
    required this.text,
    required this.type,
    required this.id,
  });

  final String? text;
  final int id;
  final TranslateType type;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: () {
          if (text == null || text!.trim().isEmpty) return;
          final targetLang = context.currentLocale.languageCode;
          context.read<TranslateCommentCubit>().translate(
                id: id,
                targetLang: targetLang,
                type: type,
              );
        },
        child: Text(
          context.localized.translateComment,
          style: AppTextStyles.fs14w600.copyWith(color: AppColors.blue43),
        ),
      ),
    );
  }
}
