import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BuildStarRaitingWidget extends StatelessWidget {
  final int selectedRating;
  final ValueChanged<int> onRatingSelected;

  const BuildStarRaitingWidget({
    Key? key,
    required this.selectedRating,
    required this.onRatingSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Container(
          margin: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => onRatingSelected(index + 1),
            child: SvgPicture.asset(AssetsConstants.notActiveStar32,
                colorFilter:
                    index < selectedRating ? const ColorFilter.mode(AppColors.starColorYellow, BlendMode.srcIn) : null),
          ),
        );
      }),
    );
  }
}
