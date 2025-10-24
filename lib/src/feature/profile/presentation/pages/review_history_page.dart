import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/presentation/widgets/dialog/toaster.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
import 'package:coment_app/src/feature/catalog/bloc/like_comment_cubit.dart';
import 'package:coment_app/src/feature/profile/bloc/my_feedbacks_cubit.dart';
import 'package:coment_app/src/feature/profile/presentation/widgets/my_feedback_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class ReviewHistoryPage extends StatefulWidget implements AutoRouteWrapper {
  const ReviewHistoryPage({super.key});

  @override
  State<ReviewHistoryPage> createState() => _ReviewHistoryPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(
        create: (context) => MyFeedbacksCubit(
          repository: context.repository.profileRepository,
        ),
      ),
      BlocProvider(
        create: (context) => LikeCommentCubit(
          repository: context.repository.catalogRepository,
        ),
      ),
    ], child: this);
  }
}

class _ReviewHistoryPageState extends State<ReviewHistoryPage> {
  // like / dislike
  List<bool> isLike = [];
  List<bool> isDislike = [];
  List<bool> pressedDislike = [];

  @override
  void initState() {
    BlocProvider.of<MyFeedbacksCubit>(context).getMyFeedbacks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyFeedbacksCubit, MyFeedbacksState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          loading: () {},
          loaded: (data) {
            isLike = [];
            isDislike = [];

            for (int i = 0; i < (data).length; i++) {
              data[i].isLike == 1 ? isLike.add(true) : isLike.add(false);
              data[i].isDislike == 1 ? isDislike.add(true) : isDislike.add(false);
              pressedDislike.add(false);
            }
          },
        );
      },
      builder: (context, state) {
        return state.maybeWhen(
          orElse: () {
            return Scaffold(
              appBar: CustomAppBar(
                quarterTurns: 0,
                title: context.localized.review_history,
                shape: const Border(),
              ),
              body: const Center(
                child: CircularProgressIndicator.adaptive(
                  backgroundColor: AppColors.mainColor,
                ),
              ),
              //doNotHaveFeedback
            );
          },
          loaded: (data) {
            return data.isNotEmpty
                ? Scaffold(
                    appBar: CustomAppBar(
                      quarterTurns: 0,
                      title: context.localized.review_history,
                      shape: const Border(),
                    ),
                    body: SingleChildScrollView(
                      child: Column(
                        children: [
                          ///
                          /// <--`replies`-->
                          ///
                          ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(bottom: 30),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return BlocListener<LikeCommentCubit, LikeCommentState>(
                                listener: (context, state) {
                                  state.maybeWhen(
                                    orElse: () {},
                                    error: (message) {
                                      Toaster.showErrorTopShortToast(context, message);
                                    },
                                    loadedLike: () {
                                      BlocProvider.of<MyFeedbacksCubit>(context).getMyFeedbacks();
                                      setState(() {});
                                    },
                                    loadedDislike: () async {
                                      if (!isLike[index] && isDislike[index] && pressedDislike[index] == false) {
                                        BlocProvider.of<LikeCommentCubit>(context)
                                            .likeComment(feedbackId: data[index].id ?? 0, type: 'like');
                                      }
                                      if (pressedDislike[index] == true && !isDislike[index]) {
                                        BlocProvider.of<LikeCommentCubit>(context)
                                            .likeComment(feedbackId: data[index].id ?? 0, type: 'dislike');
                                      }
                                      BlocProvider.of<MyFeedbacksCubit>(context).getMyFeedbacks();

                                      setState(() {});
                                    },
                                  );
                                },
                                child: Column(
                                  children: [
                                    // const Gap(14),
                                    MyFeedbackItem(
                                      feedbackDTO: data[index],
                                      onTap: () {
                                        context.router
                                            .push(FeedbackDetailRoute(
                                                needPageCard: true,
                                                id: data[index].id ?? 0,
                                                userId: data[index].user?.id ?? 0))
                                            .whenComplete(() {
                                          // ignore: use_build_context_synchronously
                                          BlocProvider.of<MyFeedbacksCubit>(context).getMyFeedbacks();
                                        });
                                      },
                                      
                                      onTapLike: () {
                                   
                                      },
                                      activeDislike: isDislike[index],
                                      activeLike: isLike[index],
                                      likesCount: data[index].likes,
                                    ),
                                    if (index != data.length - 1)
                                      const Divider(
                                        thickness: 0.4,
                                        height: 0.4,
                                        color: AppColors.borderTextField,
                                      )
                                  ],
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  )
                : Scaffold(
                    appBar: CustomAppBar(
                      quarterTurns: 0,
                      title: context.localized.review_history,
                      shape: const Border(),
                    ),
                    body: Center(
                        child: Text(
                      context.localized.doNotHaveFeedback,
                      style: AppTextStyles.fs14w400,
                    )),
                  );
          },
        );
      },
    );
  }
}
