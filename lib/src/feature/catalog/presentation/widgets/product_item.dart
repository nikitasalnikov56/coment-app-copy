import 'package:cached_network_image/cached_network_image.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/constant/constants.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/core/utils/image_util.dart';
import 'package:coment_app/src/feature/main/model/product_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({
    super.key,
    required this.product,
    this.onTap,
    this.onTapBranch,
  });

  final ProductDTO product;
  final void Function()? onTap;
  final void Function()? onTapBranch;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(24),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              height: 124,
              width: 124,
              decoration: BoxDecoration(
                color: AppColors.backgroundColor2,
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CachedNetworkImage(
                  imageUrl: product.image ?? NOT_FOUND_IMAGE,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  progressIndicatorBuilder: ImageUtil.cachedLoadingBuilder,
                ),
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.fs16w500.copyWith(height: 1.4),
                  ),
                  const Gap(12),
                  Row(
                    children: [
                      SvgPicture.asset(AssetsConstants.icStar),
                      const Gap(6),
                      Text(
                        product.rating != null
                            ? product.rating.toString()
                            : '0',
                        style: AppTextStyles.fs14w500.copyWith(height: 1.2),
                      ),
                      const Gap(10),
                      Text(
                        // '(${(product.feedbackCount ?? 0) == 1
                        //     // Если количество отзывов равно 1, используем 'отзыв' (feedbackLittle)
                        //     ? '${product.feedbackCount} ${context.localized.feedbackLittle}'
                        //     // В противном случае используем 'отзывов' (reviewsLittle).
                        //     : '${product.feedbackCount ?? 0} ${context.localized.reviewsLittle}'})',
                        product.feedbackCount == 1
                            ? '(${product.feedbackCount}  ${context.localized.feedbackLittle})'
                            : '(${product.feedbackCount}  ${context.localized.reviewsLittle})',
                        style: AppTextStyles.fs14w500.copyWith(
                            height: 1.2, color: AppColors.greyTextColor2),
                      ),
                    ],
                  ),
                  const Gap(12),
                  if (product.branches != null &&
                      (product.branches ?? []).isNotEmpty)
                    GestureDetector(
                      onTap: onTapBranch,
                      child: Row(
                        children: [
                          Text(
                            'Выбрать филиал',
                            style: AppTextStyles.fs14w500.copyWith(
                                height: 1.2, color: AppColors.mainColor),
                          ),
                          const Gap(10),
                          SvgPicture.asset(
                            AssetsConstants.shevronDown,
                            colorFilter: const ColorFilter.mode(
                                AppColors.mainColor, BlendMode.srcIn),
                          ),
                        ],
                      ),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
