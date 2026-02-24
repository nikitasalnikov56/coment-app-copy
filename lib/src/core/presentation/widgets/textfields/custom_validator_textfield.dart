import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coment_app/src/core/presentation/widgets/error/error_text_widget.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/feature/auth/presentation/widgets/password_eye_suffix_icon.dart';

class CustomValidatorTextfield extends StatelessWidget {
  const CustomValidatorTextfield({
    super.key,
    required this.controller,
    this.validator,
    required this.valueListenable,
    this.onChanged,
    this.hintText,
    this.obscureText,
    this.inputFormatters,
    this.suffixIcon,
    this.onTap,
    this.autofocus = false,
    this.readOnly = false,
    this.keyboardType,
    this.focusNode,
    this.style = AppTextStyles.fs16w400h1_6,
    this.helperText,
    this.height,
    this.focusedBorder,
    this.enabledBorder,
    this.prefixIconWidget,
  });

  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueNotifier<String?> valueListenable;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final String? hintText;
  final ValueNotifier<bool>? obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final bool autofocus;
  final bool readOnly;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final TextStyle? style;
  final String? helperText;
  final double? height;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final Widget? prefixIconWidget;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: valueListenable,
      builder: (context, v, c) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 44,
              child: TextFormField(
                
                readOnly: readOnly,
                onTap: onTap,
                autofocus: autofocus,
                autocorrect: false,
                focusNode: focusNode,
                obscureText: obscureText?.value ?? false,
                obscuringCharacter: '*',
                style: style,
                inputFormatters: inputFormatters,
                textAlignVertical: TextAlignVertical.center,
                keyboardType: keyboardType,
                controller: controller,
                onChanged: onChanged,
                cursorHeight: 18,
                validator: validator,
                decoration: InputDecoration(
                  helperText: helperText,
                  focusedBorder: focusedBorder ?? OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12)),
                  errorBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 1, color: AppColors.red2),
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: enabledBorder ?? OutlineInputBorder(
                      borderSide: const BorderSide(
                          width: 1, color: AppColors.borderTextField),
                      borderRadius: BorderRadius.circular(12)),
                  fillColor: v == null ? null : AppColors.muteRed,
                  prefixIcon: prefixIconWidget ,
                  suffixIcon: obscureText != null
                      ? PasswordEyeSuffixIcon(
                          valueListenable: obscureText!,
                          hasError: valueListenable.value != null,
                        )
                      : suffixIcon,
                  hintText: hintText,
                  hintStyle: AppTextStyles.fs14w500
                      .copyWith(color: AppColors.base400, height: 1.55),
                  errorStyle: const TextStyle(
                    height: 0,
                    fontSize: 0,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: ErrorTextWidget(
                text: valueListenable.value,
              ),
            ),
          ],
        );
      },
    );
  }
}
