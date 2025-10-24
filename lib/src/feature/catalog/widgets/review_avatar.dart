import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/image_util.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ReviewAvatar extends StatelessWidget {
  final String imageAva;
  final int rating;

  const ReviewAvatar({
    super.key,
    required this.imageAva,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () => context.router.push(DetailAvatarRoute(image: imageAva)),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              height: 44,
              width: 44,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:  0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(100)),
                child: CachedNetworkImage(
                  imageUrl: imageAva,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: ImageUtil.cachedLoadingBuilder,
                ),
              ),
            ),
          ),

          // Rating overlay
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(rating.toString(), style: AppTextStyles.fs12w400),
                  const SizedBox(width: 4),
                  SvgPicture.asset(
                    AssetsConstants.icStar,
                    height: 12,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
