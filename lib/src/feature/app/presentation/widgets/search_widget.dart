import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:coment_app/src/core/theme/resources.dart';

class SearchWidget extends StatefulWidget {
  final TextEditingController? searchController;
  final bool? readOnly;
  final InputBorder? focusedBorder;
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final Widget? suffixIcon;
  final BoxConstraints? suffixIconConstraints;
  final bool? autofocus;

  const SearchWidget({
    super.key,
    this.searchController,
    this.readOnly,
    this.focusedBorder,
    this.onTap,
    this.suffixIcon,
    this.suffixIconConstraints,
    this.onChanged,
    this.onFieldSubmitted,
    this.autofocus,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 46,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context)
              .inputDecorationTheme
              .fillColor, // BorderRadius applied to the Container
        ),
        child: TextFormField(
          autofocus: widget.autofocus ?? false,
          readOnly: widget.readOnly ?? false,
          controller: widget.searchController,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            isCollapsed: true,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(
                top: 12,
                bottom: 12,
              ),
              child: SvgPicture.asset(
                AssetsConstants.search,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).iconTheme.color ?? Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
            ),
            hintText: context.localized.search,
            hintStyle: AppTextStyles.fs16w500.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            suffixIcon: widget.suffixIcon,
            suffixIconConstraints: widget.suffixIconConstraints,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 0.5,
              ),
            ),
            focusedBorder: widget.focusedBorder ??
            OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:  BorderSide(color: Theme.of(context).colorScheme.primary, width: 0.5)),
          ),
          style:  TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          textAlignVertical: TextAlignVertical.center,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted ??
              (value) {
                if (value.isNotEmpty) {}
              },
        ),
      ),
    );
  }
}
