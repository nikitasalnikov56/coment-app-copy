import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/constant/constants.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/catalog/presentation/widgets/translate_reply_widget.dart';
import 'package:coment_app/src/feature/catalog/widgets/review_avatar.dart';
import 'package:coment_app/src/feature/main/model/feedback_dto.dart';
import 'package:coment_app/src/feature/main/presentation/widgets/popular_feedback_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class FeedbackRepliesItem extends StatefulWidget {
  final String imageAva;
  final String name;
  final DateTime date;
  final String coment;
  final int rating;
  final List<ReplyDTO> replies;
  final VoidCallback onReplyPressed;
  final VoidCallback onReplyReplyPressed;
  final void Function(String name, int parentId, bool isAnswerBottomSheet)
      selectedFeedback;

  const FeedbackRepliesItem({
    super.key,
    required this.imageAva,
    required this.name,
    required this.date,
    required this.coment,
    required this.rating,
    required this.onReplyPressed,
    required this.replies,
    required this.onReplyReplyPressed,
    required this.selectedFeedback,
  });

  @override
  State<FeedbackRepliesItem> createState() => _FeedbackRepliesItemState();
}

class _FeedbackRepliesItemState extends State<FeedbackRepliesItem> {
  bool showReplyInput = false;
  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReviewAvatar(
              imageAva: widget.imageAva,
              rating: widget.rating,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: AppTextStyles.fs14w600.copyWith(
                      color: const Color(0xff605b5b),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDate(widget.date, context.currentLocale.toString()),
                    style: AppTextStyles.fs12w500.copyWith(
                      color: const Color(0xFFA7A7A7),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.coment,
                    style: AppTextStyles.fs14w400.copyWith(
                        color: AppColors.text,
                        height: 1.3,
                        letterSpacing: -0.5),
                  ),
                  const Gap(4),

                  // ///
                  // /// <--`answer button`-->
                  // ///
                  // InkWell(
                  //   splashColor: Colors.transparent,
                  //   highlightColor: Colors.transparent,
                  //   onTap: widget.onReplyPressed,
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(top: 4, bottom: 4, right: 4),
                  //     child: Text(context.localized.answer,
                  //         style: AppTextStyles.fs12w500.copyWith(color: AppColors.greyTextColor3)),
                  //   ),
                  // ),
                  // const Gap(10),

              /// 
              ///  <--`translate button`-->
              /// 
                   TranslateReplyWidget(replyComment:widget.coment),
                  const Gap(10),
                  
                  ///
                  /// <--`replies`-->
                  ///
                  if (widget.replies.isNotEmpty)
                    ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, subindex) {
                          return ReplyFeedbackItem(
                            reply: widget.replies[subindex],
                            parentName: widget.name,
                            selectedFeedback:
                                (name, parentId, isAnswerBottomSheet) {
                              widget.selectedFeedback
                                  .call(name, parentId, isAnswerBottomSheet);
                            },
                            onAnswerTapped: () {
                              widget.selectedFeedback.call(
                                  widget.replies[subindex].user?.name ?? '',
                                  widget.replies[subindex].id ?? 0,
                                  true);
                            },
                            depth: 0,
                          );
                        },
                        separatorBuilder: (context, index) => const Gap(1),
                        itemCount: widget.replies.length)
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  ColorFilter? getStarColorFilter(int rating, int index) {
    return rating == 5
        ? null
        : rating == 4
            ? (index == 4
                ? const ColorFilter.mode(AppColors.base400, BlendMode.srcIn)
                : null)
            : rating == 3
                ? (index == 3 || index == 4
                    ? const ColorFilter.mode(AppColors.base400, BlendMode.srcIn)
                    : null)
                : rating == 2
                    ? (index == 2 || index == 3 || index == 4
                        ? const ColorFilter.mode(
                            AppColors.base400, BlendMode.srcIn)
                        : null)
                    : rating == 1
                        ? (index == 1 || index == 2 || index == 3 || index == 4
                            ? const ColorFilter.mode(
                                AppColors.base400, BlendMode.srcIn)
                            : null)
                        : (index == 0 ||
                                index == 1 ||
                                index == 2 ||
                                index == 3 ||
                                index == 4
                            ? const ColorFilter.mode(
                                AppColors.base400, BlendMode.srcIn)
                            : null);
  }
}

class ReplyFeedbackItem extends StatelessWidget {
  const ReplyFeedbackItem({
    super.key,
    this.reply,
    this.onAnswerTapped,
    this.replyTwo,
    required this.selectedFeedback,
    required this.parentName,
    this.depth = 0,
  });

  final ReplyDTO? reply;
  final String parentName;
  final ReplyTwoDTO? replyTwo;
  final int depth;
  final void Function()? onAnswerTapped;
  final void Function(String name, int parentId, bool isAnswerBottomSheet)
      selectedFeedback;

  @override
  Widget build(BuildContext context) {
    if (depth > 3) return const SizedBox();
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReviewAvatar(
              imageAva: reply?.user?.avatar ??
                  replyTwo?.user?.avatar ??
                  NOT_FOUND_IMAGE,
              rating: reply?.user?.rating ?? replyTwo?.user?.rating ?? 1,
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
                          Row(
                            children: [
                              Text(
                                  reply?.user?.name ??
                                      replyTwo?.user?.name ??
                                      '',
                                  style: AppTextStyles.fs14w600.copyWith(
                                      color: const Color(0xff605b5b),
                                      height: 1.3)),
                              const Gap(4),
                              if (replyTwo != null)
                                SvgPicture.asset(AssetsConstants.next),
                              const Gap(4),
                              if (replyTwo != null)
                                Text(parentName,
                                    style: AppTextStyles.fs14w600.copyWith(
                                      color: const Color(0xff605b5b),
                                    ))
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                              reply?.createdAt != null
                                  ? formatDate(reply!.createdAt!,
                                      context.currentLocale.toString())
                                  : '—',
                              style: AppTextStyles.fs12w500.copyWith(
                                  color: const Color(0xFFA7A7A7), height: 1.3)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reply?.comment ?? replyTwo?.comment ?? '',
                    style: AppTextStyles.fs14w400.copyWith(
                        color: AppColors.text,
                        height: 1.3,
                        letterSpacing: -0.5),
                  ),
                  const Gap(4),
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: onAnswerTapped,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 4, bottom: 4, right: 4),
                      child: Text(context.localized.answer,
                          style: AppTextStyles.fs12w500
                              .copyWith(color: AppColors.greyTextColor3)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Gap(14),

        ///
        /// <--`replies`-->
        ///
        if (reply != null && (reply?.reply ?? []).isNotEmpty)
          // if ((reply?.reply ?? []).isNotEmpty)
          ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, subindex) {
                return ReplyFeedbackItem(
                  reply: null,
                  replyTwo: reply?.reply?[subindex],
                  onAnswerTapped: () {
                    selectedFeedback.call(
                        reply?.reply?[subindex].user?.name ?? '',
                        reply?.reply?[subindex].id ?? 0,
                        true);
                  },
                  selectedFeedback: (name, parentId, isAnswerBottomSheet) {
                    selectedFeedback.call(name, parentId, isAnswerBottomSheet);
                  },
                  parentName: reply?.user?.name ?? '',
                  depth: depth + 1,
                );
              },
              separatorBuilder: (context, index) => const Gap(14),
              itemCount: reply?.reply?.length ?? 0),
        if (replyTwo != null && (replyTwo?.reply ?? []).isNotEmpty)
          // if ((replyTwo?.reply ?? []).isNotEmpty)
          ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, subindex) {
                return ReplyFeedbackItem(
                  reply: replyTwo?.reply?[subindex],
                  replyTwo: null,
                  onAnswerTapped: () {
                    selectedFeedback.call(
                        replyTwo?.reply?[subindex].user?.name ?? '',
                        replyTwo?.reply?[subindex].parentId ?? 0,
                        true);
                  },
                  selectedFeedback: (name, parentId, isAnswerBottomSheet) {
                    selectedFeedback.call(name, parentId, isAnswerBottomSheet);
                  },
                  parentName: replyTwo?.user?.name ?? '',
                  depth: depth + 1,
                );
              },
              separatorBuilder: (context, index) => const Gap(14),
              itemCount: replyTwo?.reply?.length ?? 0)
      ],
    );
  }
}
