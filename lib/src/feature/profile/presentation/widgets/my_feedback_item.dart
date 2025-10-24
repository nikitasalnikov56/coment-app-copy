import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/constant/constants.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/core/utils/image_util.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
import 'package:coment_app/src/feature/catalog/widgets/review_avatar.dart';
import 'package:coment_app/src/feature/main/model/feedback_dto.dart';
import 'package:coment_app/src/feature/main/presentation/widgets/popular_feedback_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class MyFeedbackItem extends StatefulWidget {
  final FeedbackDTO feedbackDTO;
  final void Function()? onTapLike;
  final void Function()? onTapDislike;
  final void Function()? onTap;
  final bool? activeLike;
  final bool? activeDislike;
  final int? likesCount;
  final int? repliesCount;

  const MyFeedbackItem({
    super.key,
    required this.feedbackDTO,
    this.onTapLike,
    this.onTapDislike,
    this.activeLike,
    this.activeDislike,
    this.likesCount,
    this.repliesCount,
    this.onTap,
  });

  @override
  State<MyFeedbackItem> createState() => _MyFeedbackItemState();
}

class _MyFeedbackItemState extends State<MyFeedbackItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 14, left: 16, right: 16, bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReviewAvatar(
              imageAva: widget.feedbackDTO.user?.avatar ?? NOT_FOUND_IMAGE,
              rating: widget.feedbackDTO.user?.rating ?? 1,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.feedbackDTO.user?.name ?? '',
                              style: AppTextStyles.fs14w600.copyWith(color: const Color(0xff605b5b), height: 1.3)),
                          const SizedBox(height: 4),
                          Text(formatDate(widget.feedbackDTO.createdAt ?? '', context.currentLocale.toString()),
                              style: AppTextStyles.fs12w500.copyWith(color: const Color(0xFFA7A7A7), height: 1.3)),
                        ],
                      ),
                      Row(
                        children: List.generate(
                            5,
                            (index) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: SvgPicture.asset(AssetsConstants.icStar,
                                    height: 10,
                                    width: 10,
                                    colorFilter: getStarColorFilter(widget.feedbackDTO.rating ?? 0, index)))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.feedbackDTO.comment ?? '',
                    style: AppTextStyles.fs14w400.copyWith(color: AppColors.text, height: 1.3, letterSpacing: -0.5),
                  ),
                  if ((widget.feedbackDTO.images ?? []).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: (widget.feedbackDTO.images ?? []).length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                context.router.push(
                                  DetailImageRoute(images: widget.feedbackDTO.images),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: SizedBox(
                                  height: 80,
                                  width: 80,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.feedbackDTO.images?[index].image ?? '',
                                      fit: BoxFit.cover,
                                      progressIndicatorBuilder: ImageUtil.cachedLoadingBuilder,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  const Gap(10),

                  ///
                  ///Like unlike Buttons
                  ///

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: widget.onTapLike,
                            child: SvgPicture.asset(
                              AssetsConstants.icLike,
                              colorFilter: const ColorFilter.mode(AppColors.mainColor, BlendMode.srcIn),
                              // colorFilter: widget.activeLike == true
                              //     ? const ColorFilter.mode(AppColors.mainColor, BlendMode.srcIn)
                              //     : const ColorFilter.mode(Color(0xffc1c0c0), BlendMode.srcIn),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(widget.feedbackDTO.likes == null ? '0' : widget.feedbackDTO.likes.toString(),
                              style: AppTextStyles.fs12w500.copyWith(color: AppColors.greyTextColor3)),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: widget.onTapDislike,
                            child: SvgPicture.asset(
                             AssetsConstants.icDislike,
                              colorFilter: widget.activeDislike == true
                                  ? const ColorFilter.mode(AppColors.mainColor, BlendMode.srcIn)
                                  : const ColorFilter.mode(Color(0xffc1c0c0), BlendMode.srcIn),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(widget.feedbackDTO.dislikes == null ? '0' : widget.feedbackDTO.dislikes.toString(),
                              style: AppTextStyles.fs12w500.copyWith(color: AppColors.greyTextColor3)),
                          const SizedBox(width: 8),
                          SvgPicture.asset(AssetsConstants.icComment),
                          const SizedBox(width: 4),
                          Text(
                            widget.feedbackDTO.repliesCount.toString(),
                            style: AppTextStyles.fs12w500.copyWith(color: AppColors.greyTextColor3),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(AssetsConstants.views),
                          const SizedBox(width: 4),
                          Text(widget.feedbackDTO.views == null ? '0' : widget.feedbackDTO.views.toString(),
                              style: AppTextStyles.fs12w500.copyWith(color: AppColors.greyTextColor3)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ColorFilter? getStarColorFilter(int rating, int index) {
    return rating == 5
        ? null
        : rating == 4
            ? (index == 4 ? const ColorFilter.mode(AppColors.base400, BlendMode.srcIn) : null)
            : rating == 3
                ? (index == 3 || index == 4 ? const ColorFilter.mode(AppColors.base400, BlendMode.srcIn) : null)
                : rating == 2
                    ? (index == 2 || index == 3 || index == 4
                        ? const ColorFilter.mode(AppColors.base400, BlendMode.srcIn)
                        : null)
                    : rating == 1
                        ? (index == 1 || index == 2 || index == 3 || index == 4
                            ? const ColorFilter.mode(AppColors.base400, BlendMode.srcIn)
                            : null)
                        : (index == 0 || index == 1 || index == 2 || index == 3 || index == 4
                            ? const ColorFilter.mode(AppColors.base400, BlendMode.srcIn)
                            : null);
  }
}
