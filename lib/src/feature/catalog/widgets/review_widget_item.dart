import 'package:auto_route/auto_route.dart';
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

class ReviewWidgetItem extends StatelessWidget {
  // final String imageAva;
  final FeedbackDTO feedbackDTO;
  final void Function()? onTapLike;
  final void Function()? onTapDislike;
  final void Function()? onTapFeedbackDetail;
  final bool? activeLike;
  final bool? activeDislike;
  final int? likesCount;
  final int? dislikesCount;
  final bool? isLikeLoading;
  final bool? isDislikeLoading;

  const ReviewWidgetItem({
    super.key,
    this.onTapLike,
    this.onTapDislike,
    required this.feedbackDTO,
    this.activeLike,
    this.activeDislike,
    this.likesCount,
    this.dislikesCount,
    this.onTapFeedbackDetail,
    this.isLikeLoading,
    this.isDislikeLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReviewAvatar(
            imageAva: feedbackDTO.user?.avatar ?? NOT_FOUND_IMAGE,
            rating: feedbackDTO.user?.rating ?? 1,
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
                        Text(feedbackDTO.user?.name ?? '',
                            style: AppTextStyles.fs14w600.copyWith(color: const Color(0xff605b5b), height: 1.3)),
                        const SizedBox(height: 4),
                        Text(
                          // formatDate(feedbackDTO.createdAt ?? '', context.currentLocale.toString()),
                          feedbackDTO.createdAt != null
                                      ? formatDate(feedbackDTO.createdAt!,
                                          context.currentLocale.toString())
                                      : '—',
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
                                  colorFilter: getStarColorFilter(feedbackDTO.rating ?? 0, index)))),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  feedbackDTO.comment ?? '',
                  style: AppTextStyles.fs14w400.copyWith(color: AppColors.text, height: 1.3, letterSpacing: -0.5),
                ),
                if ((feedbackDTO.images ?? []).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: feedbackDTO.images?.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              context.router.push(
                                DetailImageRoute(
                                  images: feedbackDTO.images,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: SizedBox(
                                height: 80,
                                width: 80,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    feedbackDTO.images?[index].image ?? '',
                                    fit: BoxFit.cover,
                                    loadingBuilder: ImageUtil.loadingBuilder,
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
                InkWell(
                  onTap: onTapFeedbackDetail,
                  child: Text(
                    context.localized.read_the_entire_review,
                    style: AppTextStyles.fs12w500.copyWith(color: AppColors.mainColor, height: 1.3),
                  ),
                ),
                const Gap(4),

                ///
                ///Like unlike Buttons
                ///

                Row(
                  children: [
                    if (isLikeLoading == true)
                      const Padding(
                        padding: EdgeInsets.all(3.0),
                        child: CircularProgressIndicator.adaptive(
                          backgroundColor: AppColors.mainColor,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: onTapLike,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: SvgPicture.asset(
                            AssetsConstants.icLike,
                            colorFilter: activeLike == true
                                ? const ColorFilter.mode(AppColors.mainColor, BlendMode.srcIn)
                                : const ColorFilter.mode(Color(0xffc1c0c0), BlendMode.srcIn),
                          ),
                        ),
                      ),
                    Text(likesCount.toString(),
                        style: AppTextStyles.fs12w500.copyWith(color: AppColors.greyTextColor3)),
                    const SizedBox(width: 4),
                    if (isDislikeLoading == true)
                      const Padding(
                        padding: EdgeInsets.all(3.0),
                        child: CircularProgressIndicator.adaptive(
                          backgroundColor: AppColors.mainColor,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: onTapDislike,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: SvgPicture.asset(
                            AssetsConstants.icDislike,
                            colorFilter: activeDislike == true
                                ? const ColorFilter.mode(AppColors.mainColor, BlendMode.srcIn)
                                : const ColorFilter.mode(Color(0xffc1c0c0), BlendMode.srcIn),
                          ),
                        ),
                      ),
                       Text(dislikesCount.toString(),
                        style: AppTextStyles.fs12w500.copyWith(color: AppColors.greyTextColor3)),
                    const SizedBox(width: 6),
                    SvgPicture.asset(AssetsConstants.icComment),
                    const SizedBox(width: 4),
                    Text(
                      feedbackDTO.repliesCount.toString(),
                      style: AppTextStyles.fs12w500.copyWith(color: AppColors.greyTextColor3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
