import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/constant/constants.dart';
import 'package:coment_app/src/core/extensions/build_context.dart';
import 'package:coment_app/src/core/presentation/widgets/dialog/toaster.dart';
import 'package:coment_app/src/core/presentation/widgets/other/custom_loading_overlay_widget.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/core/utils/image_util.dart';
import 'package:coment_app/src/feature/app/logic/reactivex_service.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
import 'package:coment_app/src/feature/catalog/bloc/complain_cubit.dart';
import 'package:coment_app/src/feature/catalog/bloc/like_comment_cubit.dart';
import 'package:coment_app/src/feature/catalog/bloc/reply_comment_cubit.dart';
import 'package:coment_app/src/feature/catalog/bloc/user_feedback_cubit.dart';
import 'package:coment_app/src/feature/catalog/presentation/widgets/translate_feedpack_widget.dart';
import 'package:coment_app/src/feature/catalog/widgets/complained_bs.dart';
import 'package:coment_app/src/feature/catalog/widgets/review_avatar.dart';
import 'package:coment_app/src/feature/main/model/feedback_dto.dart';
import 'package:coment_app/src/feature/main/presentation/widgets/popular_feedback_item.dart';
import 'package:flutter/material.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/catalog/widgets/feedback_replies_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:loader_overlay/loader_overlay.dart';

@RoutePage()
class FeedbackDetailPage extends StatefulWidget implements AutoRouteWrapper {
  final int id;
  final int userId;
  final bool needPageCard;

  const FeedbackDetailPage({
    Key? key,
    required this.id,
    required this.userId,
    required this.needPageCard,
  }) : super(key: key);

  @override
  State<FeedbackDetailPage> createState() => _FeedbackDetailPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(
        create: (context) => UserFeedbackCubit(
          repository: context.repository.catalogRepository,
        ),
      ),
      BlocProvider(
        create: (context) => ReplyCommentCubit(
          repository: context.repository.catalogRepository,
        ),
      ),
      BlocProvider(
        create: (context) => LikeCommentCubit(
          repository: context.repository.catalogRepository,
        ),
      ),
      BlocProvider(
        create: (context) => ComplainCubit(
          repository: context.repository.catalogRepository,
        ),
      ),
    ], child: this);
  }
}

class _FeedbackDetailPageState extends State<FeedbackDetailPage> {
  bool isAnswerBottomSheet = false;

  String feedbackUserName = '';
  int parentId = 0;

  final TextEditingController _replyController = TextEditingController();

  bool repliesVisible = true;

  bool isLoading = false;

  // like, dislike
  bool isLike = false;
  bool isDislike = false;
  bool pressedDislike = false;

  bool isLikeLoading = false;
  bool isDislikeLoading = false;
  int? userId;

  @override
  void initState() {
    ReactiveXService().pushRepeater.stream.listen(
      (event) {
        if (!mounted) return;
        log('init refresh notificaion');
        BlocProvider.of<UserFeedbackCubit>(context)
            .userFeedback(id: widget.id, isView: '');
      },
    );
    log('${context.repository.authRepository.user?.id} ===== ${widget.userId}');
    BlocProvider.of<UserFeedbackCubit>(context).userFeedback(
        id: widget.id,
        isView: context.repository.authRepository.user?.id == widget.userId
            ? ''
            : 'true');
    super.initState();

    //_likesCount = widget.likes;
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      overlayColor: AppColors.barrierColor,
      overlayWidgetBuilder: (progress) => const CustomLoadingOverlayWidget(),
      child: BlocConsumer<UserFeedbackCubit, UserFeedbackState>(
          listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          loading: () {},
          loaded: (feedbackDTO) {
            userId = feedbackDTO.user?.id;

            feedbackDTO.isLike == 1 ? isLike = true : isLike = false;
            feedbackDTO.isDislike == 1 ? isDislike = true : isDislike = false;
          },
        );
      }, builder: (context, state) {
        return state.maybeWhen(
          orElse: () {
            return Scaffold(
              appBar: CustomAppBar(
                title: context.localized.feedback,
                quarterTurns: 0,
                actions: [
                  const Gap(16),
                  GestureDetector(
                    // onTap: () => _showBottomSheet(context),
                    child: SvgPicture.asset(AssetsConstants.icThreeDots),
                  ),
                  const Gap(16),
                ],
              ),
              body: const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          },
          loaded: (feedbackDTO) {
            return Scaffold(
              appBar: CustomAppBar(
                title: context.localized.feedback,
                quarterTurns: 0,
                actions: [
                  IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _showBottomSheet(context);
                      },
                      splashRadius: 21,
                      icon: SvgPicture.asset(AssetsConstants.icThreeDots)),
                  const Gap(10)
                ],
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///
                      /// <--`main feedback`-->
                      ///
                      _mainFeedback(feedbackDTO),

                      ///
                      /// <--`enter to card detail page`-->
                      ///
                      if (widget.needPageCard)
                        GestureDetector(
                          onTap: () {
                            context.router.push(ProductDetailRoute(
                                productId: feedbackDTO.item?.id ?? 0));
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, left: 56),
                            child: Text(
                              context.localized.goToCard,
                              style: AppTextStyles.fs12w500.copyWith(
                                  color: AppColors.mainColor,
                                  height: 1.3,
                                  letterSpacing: -0.5),
                            ),
                          ),
                        ),

                      ///
                      /// <--`divider, show replies`-->
                      ///
                      _visibleDivider(feedbackDTO),

                      ///
                      /// <--`replies`-->
                      ///
                      if (repliesVisible)
                        ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(bottom: 15),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: feedbackDTO.replies?.length,
                          itemBuilder: (context, index) {
                            final reply = feedbackDTO.replies?[index];
                            // ⚠️ ПРОПУСКАЕМ, ЕСЛИ ЭТО ЛАЙК (оценка без текста)
                            if (reply?.comment == null ||
                                reply!.comment!.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              children: [
                                FeedbackRepliesItem(
                                  onReplyPressed: () {
                                    feedbackUserName = feedbackDTO
                                            .replies?[index].user?.name ??
                                        '';
                                    parentId =
                                        feedbackDTO.replies?[index].id ?? 0;
                                    isAnswerBottomSheet = true;
                                    log('first ${feedbackDTO.replies?[index].user?.name}, ${feedbackDTO.replies?[index].id}, $isAnswerBottomSheet');
                                    setState(() {});
                                  },
                                  onReplyReplyPressed: () {
                                    // feedbackUserName = feedbackDTO.replies?[index].user?.name ?? '';
                                    // parentId = feedbackDTO.replies?[index].id ?? 0;
                                    // isAnswerBottomSheet = true;
                                    // setState(() {});
                                  },
                                  imageAva: feedbackDTO
                                          .replies?[index].user?.avatar ??
                                      NOT_FOUND_IMAGE,
                                  name:
                                      feedbackDTO.replies?[index].user?.name ??
                                          '',
                                  date: feedbackDTO.replies?[index].createdAt ??
                                      DateTime.now(),
                                  coment:
                                      feedbackDTO.replies?[index].comment ?? '',
                                  rating: feedbackDTO
                                          .replies?[index].user?.rating ??
                                      1,
                                  replies:
                                      feedbackDTO.replies?[index].reply ?? [],
                                  selectedFeedback:
                                      (name, parentI, isAnswerBottomShee) {
                                    feedbackUserName = name;
                                    parentId = parentI;
                                    isAnswerBottomSheet = isAnswerBottomShee;
                                    log('$name, $parentId, $isAnswerBottomShee');
                                    setState(() {});
                                  },
                                ),

                                // const Gap(15),
                                // const Divider(
                                //   thickness: 0.4,
                                //   height: 0.4,
                                //   color: AppColors.borderTextField,
                                // )
                              ],
                            );
                          },
                        ),

                      if (isAnswerBottomSheet == true)
                        const Gap(100)
                      else
                        const Gap(20)
                    ],
                  ),
                ),
              ),
              bottomSheet: isAnswerBottomSheet
                  ? BlocListener<ReplyCommentCubit, ReplyCommentState>(
                      listener: (context, state) {
                        state.maybeWhen(
                          orElse: () {
                            // isLoading = false;
                            // setState(() {});
                            context.loaderOverlay.hide();
                          },
                          loading: () {
                            context.loaderOverlay.show();
                            // isLoading = true;
                            // setState(() {});
                          },
                          loaded: (wasToxic, warningCount) {
                            // isLoading = false;
                            context.loaderOverlay.hide();
                            if (wasToxic) {
                              if (warningCount >= 4) {
                                _showToxicDialog(context, true);
                              } else {
                                _showToxicDialog(context, false);
                              }
                            }
                            // // Возвращаемся на ProductDetail
                            // context.router.popUntil((r) =>
                            //     r.settings.name == ProductDetailRoute.name);
                            BlocProvider.of<UserFeedbackCubit>(context)
                                .userFeedback(id: widget.id, isView: '');
                            isAnswerBottomSheet = false;
                            _replyController.clear();
                            setState(() {});
                          },
                          hidden: () {
                            context.loaderOverlay.hide();
                            _showHiddenReplyDialog(context);
                            // context.router.popUntil((r) =>
                            //     r.settings.name == ProductDetailRoute.name);
                          },
                        );
                      },
                      child: _bottomSheet())
                  : Container(height: 1),
            );
          },
        );
      }),
    );
  }

  void _showToxicDialog(BuildContext context, bool isModeration) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Внимание'),
        content: Text(
          isModeration
              ? 'Вы нарушили правила. Ответ отправлен на модерацию.'
              : 'Ваш ответ содержал недопустимые выражения и был исправлен.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHiddenReplyDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Ответ не опубликован'),
        content: const Text(
            'Ответ содержит запрещённый контент и не может быть опубликован.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _mainFeedback(FeedbackDTO feedbackDTO) {
    return Row(
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
                          style: AppTextStyles.fs14w600.copyWith(
                              color: const Color(0xff605b5b), height: 1.3)),
                      const SizedBox(height: 4),
                      Text(
                          feedbackDTO.createdAt != null
                              ? formatDate(feedbackDTO.createdAt!,
                                  context.currentLocale.toString())
                              : '—',
                          style: AppTextStyles.fs12w500.copyWith(
                              color: const Color(0xFFA7A7A7), height: 1.3)),
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
                                colorFilter: getStarColorFilter(
                                    feedbackDTO.rating ?? 0, index)))),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                feedbackDTO.comment ?? '',
                style: AppTextStyles.fs14w400.copyWith(
                    color: AppColors.text, height: 1.3, letterSpacing: -0.5),
              ),

              ///
              /// <--`feedback images`-->
              ///
              if ((feedbackDTO.images ?? []).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: feedbackDTO.images?.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            context.router.push(
                                DetailImageRoute(images: feedbackDTO.images));
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: SizedBox(
                              height: 80,
                              width: 80,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      feedbackDTO.images?[index].image ?? '',
                                  fit: BoxFit.cover,
                                  progressIndicatorBuilder:
                                      ImageUtil.cachedLoadingBuilder,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              const Gap(4),

              BlocConsumer<LikeCommentCubit, LikeCommentState>(
                listener: (context, state) {
                  state.maybeWhen(
                    orElse: () {
                      // Только для безопасности — скрыть спиннеры при неожиданном состоянии
                      isLikeLoading = false;
                      isDislikeLoading = false;
                      setState(() {});
                    },
                    loading: () {
                      // Уже управляется в onTap — можно оставить пустым или логировать
                    },
                    error: (message) {
                      isLikeLoading = false;
                      isDislikeLoading = false;
                      setState(() {});
                      Toaster.showErrorTopShortToast(context, message);
                    },
                    loadedLike: () {
                      isLikeLoading = false;
                      isDislikeLoading = false;
                      setState(() {});
                      // Просто перезагружаем данные отзыва
                      BlocProvider.of<UserFeedbackCubit>(context)
                          .userFeedback(id: widget.id, isView: '');
                    },
                    loadedDislike: () {
                      isLikeLoading = false;
                      isDislikeLoading = false;
                      setState(() {});
                      // Просто перезагружаем данные отзыва
                      BlocProvider.of<UserFeedbackCubit>(context)
                          .userFeedback(id: widget.id, isView: '');
                    },
                  );
                },
                builder: (context, state) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: context.appBloc.isAuthenticated
                                ? () {
                                    if (isLike) return;
                                    if (isDislike) {
                                      return;
                                    }
                                    isLikeLoading = true;
                                    setState(() {});
                                    BlocProvider.of<LikeCommentCubit>(context)
                                        .likeComment(
                                      feedbackId: feedbackDTO.id ?? 0,
                                      type: 'like',
                                    );
                                    pressedDislike = false;
                                  }
                                : () {
                                    context.router.push(const RegisterRoute());
                                  },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: SvgPicture.asset(
                                AssetsConstants.icLike,
                                colorFilter: !pressedDislike
                                    ? const ColorFilter.mode(
                                        AppColors.mainColor, BlendMode.srcIn)
                                    : null,
                              ),
                            ),
                          ),
                          Text(
                            (feedbackDTO.likes ?? 0).toString(),
                            style: AppTextStyles.fs12w500
                                .copyWith(color: AppColors.greyTextColor3),
                          ),
                          const SizedBox(width: 4),
                          if (isDislikeLoading)
                            const Padding(
                              padding: EdgeInsets.all(3.0),
                              child: CircularProgressIndicator.adaptive(
                                backgroundColor: AppColors.mainColor,
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: context.appBloc.isAuthenticated
                                  ? () {
                                      if (isDislike) {
                                        return;
                                      }
                                      if (isLike) {
                                        return;
                                      }
                                      BlocProvider.of<LikeCommentCubit>(context)
                                          .likeComment(
                                        feedbackId: feedbackDTO.id ?? 0,
                                        type: 'dislike',
                                      );
                                      pressedDislike = true;
                                    }
                                  : () {
                                      context.router
                                          .push(const RegisterRoute());
                                    },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SvgPicture.asset(
                                  AssetsConstants.icDislike,
                                  colorFilter: pressedDislike
                                      ? const ColorFilter.mode(
                                          AppColors.mainColor, BlendMode.srcIn)
                                      : const ColorFilter.mode(
                                          Color(0xffc1c0c0), BlendMode.srcIn),
                                ),
                              ),
                            ),
                          Text(
                            (feedbackDTO.dislikes ?? 0).toString(),
                            style: AppTextStyles.fs12w500
                                .copyWith(color: AppColors.greyTextColor3),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: context.appBloc.isAuthenticated
                                ? () {
                                    feedbackUserName =
                                        feedbackDTO.user?.name ?? '';
                                    parentId = 0;
                                    isAnswerBottomSheet = true;
                                    setState(() {});
                                  }
                                : () {
                                    context.router.push(const RegisterRoute());
                                  },
                            child: Text(
                              context.localized.answer,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.greyText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TranslateFeedpackWidget(feedbackComment: feedbackDTO.comment,),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bottomSheet() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "${context.localized.answer}: ",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                      TextSpan(
                        text: feedbackUserName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    isAnswerBottomSheet = false;
                    _replyController.clear();
                    setState(() {});
                  },
                  child: SvgPicture.asset(
                    AssetsConstants.icClose,
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    onChanged: (value) {
                      _replyController.text.isNotEmpty;
                      setState(() {});
                    },
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: context.localized.your_response_to_the_comment,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                if (_replyController.text.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  isLoading
                      ? const CircularProgressIndicator.adaptive()
                      : IconButton(
                          icon: SvgPicture.asset(
                            AssetsConstants.icSend,
                          ),
                          onPressed: () {
                            BlocProvider.of<ReplyCommentCubit>(context)
                                .writeReplyComment(
                                    feedbackId: widget.id,
                                    comment: _replyController.text,
                                    parentId: parentId != 0 ? parentId : null);
                            log('${widget.id}');
                            log(_replyController.text);
                          },
                        ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _visibleDivider(FeedbackDTO feedbackDTO) {
    return Row(
      children: [
        Container(
          height: 0.4,
          width: 80,
          decoration: const BoxDecoration(
            color: AppColors.borderTextField,
          ),
        ),
        const Gap(10),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            repliesVisible = !repliesVisible;
            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12, right: 12),
            child: Row(
              children: [
                Text(
                  '${context.localized.view} ${feedbackDTO.replies?.length} ${context.localized.answers}', // view  // answers
                  style: AppTextStyles.fs12w500.copyWith(
                      color: AppColors.base400,
                      height: 1.3,
                      letterSpacing: -0.5),
                ),
                const Gap(10),
                AnimatedRotation(
                  turns: repliesVisible ? 0 : -0.25,
                  duration: const Duration(milliseconds: 300),
                  child: SvgPicture.asset(AssetsConstants.icArrowTr),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: context.appBloc.isAuthenticated
                      ? () {
                          Navigator.of(context).pop();
                          ComplainedBs.show(context,
                              feedID: widget.id, isDislike: false);
                        }
                      : () {
                          context.router.push(const RegisterRoute());
                        },
                  child: Text(
                    context.localized.complain,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    context.localized.cancel,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
