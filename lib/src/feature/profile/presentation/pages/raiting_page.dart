import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

@RoutePage()
class RaitingPage extends StatelessWidget {
  const RaitingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        quarterTurns: 0,
        title: context.localized.rating,
        shape: const Border(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explanation Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.localized.how_is_your_rating_calculated,
                        style: AppTextStyles.fs14w600,
                      ),
                      const Gap(6),
                      Text(
                        context.localized.your_rating_depends_on_the_number,
                        style: AppTextStyles.fs12w400,
                      ),
                    ],
                  ),
                ),
                const Gap(6),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: SvgPicture.asset(
                     AssetsConstants.icStar,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(20),

            // Purple Container with Rating Formula
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mainColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.localized.the_base_rating_starts_from,
                      style: AppTextStyles.fs14w600.copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(
                    context.localized.calculation_formula_each_like_adds,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.localized.popularity_bonus,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(20),

            // Footer Section
            Text(context.localized.theRatingUpdate, style: AppTextStyles.fs14w400),
            Text(context.localized.yourRating, style: AppTextStyles.fs14w400),
          ],
        ),
      ),
    );
  }
}
