import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class RaitingDetail extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, double> ratingDistribution;

  const RaitingDetail({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(averageRating.toStringAsFixed(1), style: AppTextStyles.fs32w700.copyWith(height: 1.3)),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                    left: 5,
                  ),
                  child: Text(
                    "из 5",
                    style: AppTextStyles.fs12w400.copyWith(color: AppColors.base400),
                  ),
                ),
              ],
            ),
            Text(
              (totalReviews == 0 || totalReviews == 1)
                  ? '($totalReviews ${context.localized.feedbackLittle})'
                  : '($totalReviews ${context.localized.reviewsLittle})',
              // "$totalReviews отзывов",
              style: AppTextStyles.fs12w500.copyWith(color: Colors.grey),
            ),
            const Gap(12)
          ],
        ),
        const Gap(12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: ratingDistribution.entries.map((entry) {
            final stars = entry.key;
            return Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: List.generate(
                      stars,
                      (index) => SvgPicture.asset(
                        AssetsConstants.star8,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        Expanded(
          child: Column(
            children: ratingDistribution.entries.map((entry) {
              final percentage = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 5, top: 2.9),
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    Expanded(
                      child: LinearProgressIndicator(
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(10),
                        value: percentage / 100,
                        backgroundColor: Colors.grey[300],
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
