// ignore_for_file: deprecated_member_use

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/constant/constants.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/core/utils/image_util.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
import 'package:coment_app/src/feature/main/model/product_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class PopularProductItem extends StatelessWidget {
  const PopularProductItem({
    super.key,
    required this.data,
  });

  final ProductDTO data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 10),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            context.router.push(ProductDetailRoute(productId: data.id ?? 0));
          },
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 160,
                width: 160,
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
                    imageUrl: data.image ?? NOT_FOUND_IMAGE,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    progressIndicatorBuilder: ImageUtil.cachedLoadingBuilder,
                  ),
                ),
              ),
              const Gap(6),
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 4),
                child: Text(
                  data.name ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.fs14w500.copyWith(height: 1.15),
                ),
              ),
              const Gap(4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data.feedbackCount == 0 || data.feedbackCount == 1
                        ? '(${data.feedbackCount} ${context.localized.feedbackLittle})'
                        : '(${data.feedbackCount} ${context.localized.reviewsLittle})',
                    style: AppTextStyles.fs12w500.copyWith(height: 1.2, color: AppColors.greyTextColor2),
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(
                        AssetsConstants.icStar,
                        height: 14,
                        width: 14,
                        colorFilter: const ColorFilter.mode(AppColors.starColorOrange, BlendMode.srcIn),
                      ),
                      const Gap(6),
                      Text(
                        '${data.rating?.toDouble()}',
                        style: AppTextStyles.fs12w500.copyWith(height: 1.2),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
