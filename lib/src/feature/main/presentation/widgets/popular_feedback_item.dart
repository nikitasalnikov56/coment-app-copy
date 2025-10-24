import 'package:cached_network_image/cached_network_image.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/constant/constants.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/core/utils/image_util.dart';
import 'package:coment_app/src/feature/main/model/feedback_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class PopularFeedbackItem extends StatelessWidget {
  const PopularFeedbackItem({
    super.key,
    required this.data,
    this.onTap,
  });

  final FeedbackDTO data;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330,
      margin: const EdgeInsets.only(right: 10),
      decoration: const BoxDecoration(color: AppColors.grey2, borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(top: 12, left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Gap(2),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: CachedNetworkImage(
                              imageUrl: data.user?.avatar ?? NOT_FOUND_IMAGE,
                              fit: BoxFit.cover,
                              height: 40,
                              width: 40,
                              progressIndicatorBuilder: ImageUtil.cachedLoadingBuilder,
                            ),
                          ),
                          const Gap(14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.user?.name ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.fs14w600.copyWith(height: 1.2),
                                ),
                                Text(
                                  formatDate(data.createdAt ?? '', context.currentLocale.toString()),
                                  style: AppTextStyles.fs12w700.copyWith(height: 1.2, color: AppColors.greyTextColor3),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: SvgPicture.asset(AssetsConstants.icStar,
                                  height: 10, width: 10, colorFilter: getStarColorFilter(data.rating ?? 0, index)));
                        },
                      ),
                    ),
                  ],
                ),
                const Gap(14),
                Text(
                  data.comment ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.fs14w400.copyWith(
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
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

String formatDate(String dateString, String locale) {
  DateTime dateTime = DateTime.parse(dateString);
  String formattedDate = DateFormat("MMMM d, yyyy", locale).format(dateTime);

  // Делаем первую букву заглавной
  return formattedDate[0].toUpperCase() + formattedDate.substring(1);
}
