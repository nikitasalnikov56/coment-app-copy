// ignore_for_file: deprecated_member_use

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coment_app/src/core/extensions/build_context.dart';
import 'package:coment_app/src/core/presentation/widgets/dialog/toaster.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/image_util.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
import 'package:coment_app/src/feature/catalog/bloc/complain_cubit.dart';
import 'package:coment_app/src/feature/catalog/bloc/like_comment_cubit.dart';
import 'package:coment_app/src/feature/catalog/bloc/product_info_cubit.dart';
import 'package:coment_app/src/feature/catalog/widgets/complained_bs.dart';
import 'package:coment_app/src/feature/catalog/widgets/raiting_detail.dart';
import 'package:coment_app/src/feature/catalog/widgets/review_widget_item.dart';
import 'package:coment_app/src/feature/main/model/feedback_dto.dart';
import 'package:coment_app/src/feature/main/model/product_dto.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class ReadAllPage extends StatefulWidget implements AutoRouteWrapper {
  const ReadAllPage({super.key, required this.data, required this.totalRatingVotes});
  final ProductDTO data;
  final int totalRatingVotes;

  @override
  State<ReadAllPage> createState() => _ReadAllPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(
          create: (context) => ProductInfoCubit(
                repository: context.repository.catalogRepository,
              )),
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

class _ReadAllPageState extends State<ReadAllPage> {
  // like / dislike
  List<bool> isLike = [];
  List<bool> isDislike = [];
  List<bool> pressedDislike = [];

  int totalRatingVotes = 0;

  @override
  void initState() {
    BlocProvider.of<ProductInfoCubit>(context).getProductInfo(id: widget.data.id ?? 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductInfoCubit, ProductInfoState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          loaded: (data) {
            isLike = [];
            isDislike = [];
            totalRatingVotes += data.ratingCounts?.five ?? 0;
            totalRatingVotes += data.ratingCounts?.four ?? 0;
            totalRatingVotes += data.ratingCounts?.three ?? 0;
            totalRatingVotes += data.ratingCounts?.two ?? 0;
            totalRatingVotes += data.ratingCounts?.one ?? 0;

            for (int i = 0; i < (data.feedback ?? []).length; i++) {
              data.feedback?[i].isLike == 1 ? isLike.add(true) : isLike.add(false);
              data.feedback?[i].isDislike == 1 ? isDislike.add(true) : isDislike.add(false);
              pressedDislike.add(false);
              // log('${data.feedback?[i].dislikes}', name: 'dis');
              // log('${data.feedback?[i].likes}', name: 'is');
              // log('$pressedDislike');
            }
          },
        );
      },
      builder: (context, state) {
        return state.maybeWhen(
          orElse: () => Scaffold(
            appBar: AppBar(
              title: Text('Оценки и отзывы (${widget.data.feedbackCount})'),
            ),
            body: const Center(
              child: Text('error'),
            ),
          ),
          loading: () => const Scaffold(
            appBar: CustomAppBar(),
            body: Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
          loaded: (data) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Оценки и отзывы (${widget.data.feedbackCount})'),
              ),
              body: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.list(
                      children: [
                        const Gap(12),

                        ///
                        /// <--`reviews raiting`-->
                        ///
                        _ratingInfo(data),
                        const Gap(22),

                        ///
                        /// <--`feedback images`-->
                        ///
                        _feedbackImages(data),
                        const Gap(14),

                        ///
                        /// <--`feedbacks`-->
                        ///

                        (data.feedback ?? []).isEmpty
                            ? Center(
                                child: Text(
                                context.localized.doNotHaveFeedback,
                                style: AppTextStyles.fs14w400,
                              ))
                            : _feedbacks(data.feedback ?? [], data.id ?? 0)

                        // ReviewWidget(
                        //   feedback: widget.data.feedback ?? [],
                        //   fromReadAllPage: true,
                        // )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  int getFeedbackItemCount(bool fromReadAllPage, List feedback) {
    if (fromReadAllPage) return feedback.length;
    return feedback.length > 2 ? 2 : feedback.length;
  }

  Widget _feedbacks(List<FeedbackDTO> feedback, int productId) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 30),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: getFeedbackItemCount(true, feedback),
      itemBuilder: (context, index) {
        return BlocListener<LikeCommentCubit, LikeCommentState>(
          listener: (context, state) {
            state.maybeWhen(
              orElse: () {},
              error: (message) {
                Toaster.showErrorTopShortToast(context, message);
              },
              loadedLike: () {
                BlocProvider.of<ProductInfoCubit>(context)
                    .getProductInfo(id: productId, hasDelay: false, hasLoading: false);
                setState(() {});
              },
              loadedDislike: () async {
                if (!isLike[index] && isDislike[index] && pressedDislike[index] == false) {
                  BlocProvider.of<LikeCommentCubit>(context)
                      .likeComment(feedbackId: feedback[index].id ?? 0, type: 'like');
                }
                if (pressedDislike[index] == true && !isDislike[index]) {
                  BlocProvider.of<LikeCommentCubit>(context)
                      .likeComment(feedbackId: feedback[index].id ?? 0, type: 'dislike');
                }
                BlocProvider.of<ProductInfoCubit>(context)
                    .getProductInfo(id: productId, hasDelay: false, hasLoading: false);
                setState(() {});
              },
            );
          },
          child: Column(
            children: [
              const Gap(14),
              ReviewWidgetItem(
                feedbackDTO: feedback[index],
                onTapDislike: context.appBloc.isAuthenticated
                    ? () {
                        if (!isDislike[index] && !isLike[index]) {
                          ComplainedBs.show(
                            context,
                            feedID: feedback[index].id,
                            isDislike: true,
                            isComplainedDislike: (isComplained) {
                              BlocProvider.of<LikeCommentCubit>(context)
                                  .likeComment(feedbackId: feedback[index].id ?? 0, type: 'dislike');
                              pressedDislike[index] = true;
                              setState(() {});
                            },
                          );
                        } else if (isDislike[index] && !isLike[index]) {
                          BlocProvider.of<LikeCommentCubit>(context)
                              .dislikeComment(feedbackId: feedback[index].id ?? 0);
                          pressedDislike[index] = true;
                          setState(() {});
                        } else if (!isDislike[index] && isLike[index]) {
                          ComplainedBs.show(
                            context,
                            feedID: feedback[index].id,
                            isDislike: true,
                            isComplainedDislike: (isComplained) {
                              BlocProvider.of<LikeCommentCubit>(context)
                                  .dislikeComment(feedbackId: feedback[index].id ?? 0);
                              pressedDislike[index] = true;
                              setState(() {});
                            },
                          );
                        }
                      }
                    : () {
                        context.router.push(const RegisterRoute());
                      },
                onTapLike: context.appBloc.isAuthenticated
                    ? () {
                        if (!isLike[index] && !isDislike[index]) {
                          BlocProvider.of<LikeCommentCubit>(context)
                              .likeComment(feedbackId: feedback[index].id ?? 0, type: 'like');
                          pressedDislike[index] = false;
                          setState(() {});
                        } else if (isLike[index] && !isDislike[index]) {
                          BlocProvider.of<LikeCommentCubit>(context)
                              .dislikeComment(feedbackId: feedback[index].id ?? 0);
                          pressedDislike[index] = false;
                          setState(() {});
                        } else if (!isLike[index] && isDislike[index]) {
                          BlocProvider.of<LikeCommentCubit>(context)
                              .dislikeComment(feedbackId: feedback[index].id ?? 0);
                          pressedDislike[index] = false;
                          setState(() {});
                        }
                      }
                    : () {
                        context.router.push(const RegisterRoute());
                      },
                onTapFeedbackDetail: () {
                  context.router
                      .push(FeedbackDetailRoute(
                          id: feedback[index].id ?? 0, userId: feedback[index].user?.id ?? 0, needPageCard: false))
                      .whenComplete(() {
                    BlocProvider.of<ProductInfoCubit>(context)
                        .getProductInfo(id: productId, hasDelay: false, hasLoading: false);
                  });
                },
                activeDislike: isDislike[index],
                activeLike: isLike[index],
                likesCount: feedback[index].likes ?? 0,
              ),
              const Gap(14),
              if (index == 0)
                const Divider(
                  thickness: 0.4,
                  height: 0.4,
                  color: AppColors.borderTextField,
                )
            ],
          ),
        );
      },
    );
  }

  Widget _feedbackImages(ProductDTO data) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              context.localized.user_photos,
              style: AppTextStyles.fs14w500,
            ),
          ],
        ),
        const Gap(10),

        ///
        /// photos
        ///
        SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment:
                (data.feedbackImages ?? []).length >= 4 ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
            children: List.generate(
              (data.feedbackImages ?? []).length > 4 ? 4 : (data.feedbackImages ?? []).length,
              (index) => Container(
                height: 80,
                margin: (data.feedbackImages ?? []).length >= 4 ? EdgeInsets.zero : const EdgeInsets.only(right: 8),
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    context.router.push(DetailAllImageRoute(images: data.feedbackImages));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: index == 3
                        ? Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: (data.feedbackImages ?? [])[index],
                                fit: BoxFit.cover,
                                height: 80,
                                width: 80,
                                progressIndicatorBuilder: ImageUtil.cachedLoadingBuilder,
                              ),
                              Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: Center(
                                  child: Text(
                                    'ЕЩЕ ${(data.feedbackImages ?? []).length - 3} +',
                                    style: AppTextStyles.fs12w600.copyWith(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : CachedNetworkImage(
                            imageUrl: (data.feedbackImages ?? [])[index],
                            fit: BoxFit.cover,
                            height: 80,
                            width: 80,
                            progressIndicatorBuilder: ImageUtil.cachedLoadingBuilder,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Gap(12),
      ],
    );
  }

  Widget _ratingInfo(ProductDTO data) {
    return RaitingDetail(
      averageRating: (data.rating ?? 0.0).toDouble(),
      totalReviews: data.feedbackCount ?? 0,
      ratingDistribution: {
        5: calculateRatingPercentage(5, data.ratingCounts?.five ?? 0, widget.totalRatingVotes),
        4: calculateRatingPercentage(4, data.ratingCounts?.four ?? 0, widget.totalRatingVotes),
        3: calculateRatingPercentage(3, data.ratingCounts?.three ?? 0, widget.totalRatingVotes),
        2: calculateRatingPercentage(2, data.ratingCounts?.two ?? 0, widget.totalRatingVotes),
        1: calculateRatingPercentage(1, data.ratingCounts?.one ?? 0, widget.totalRatingVotes),
      },
    );
  }

  double calculateRatingPercentage(int star, int starCount, int totalVotes) {
    if (totalVotes == 0) return 0.0;
    return (starCount / totalVotes) * 100;
  }
}
