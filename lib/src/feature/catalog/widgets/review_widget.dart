// import 'package:auto_route/auto_route.dart';
// import 'package:coment_app/src/core/constant/constants.dart';
// import 'package:coment_app/src/core/presentation/widgets/dialog/toaster.dart';
// import 'package:coment_app/src/core/theme/resources.dart';
// import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
// import 'package:coment_app/src/feature/catalog/bloc/complain_cubit.dart';
// import 'package:coment_app/src/feature/catalog/bloc/like_comment_cubit.dart';
// import 'package:coment_app/src/feature/catalog/widgets/complained_bs.dart';
// import 'package:coment_app/src/feature/main/model/feedback_dto.dart';
// import 'package:coment_app/src/feature/main/presentation/widgets/popular_feedback_item.dart';
// import 'package:flutter/material.dart';
// import 'package:coment_app/src/feature/catalog/widgets/review_widget_item.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:gap/gap.dart';

// class ReviewWidget extends StatefulWidget {
//   final List<FeedbackDTO> feedback;
//   final bool fromReadAllPage;

//   const ReviewWidget({
//     Key? key,
//     required this.feedback,
//     required this.fromReadAllPage,
//   }) : super(key: key);

//   @override
//   State<ReviewWidget> createState() => _ReviewWidgetState();
// }

// class _ReviewWidgetState extends State<ReviewWidget> {
//   bool isLike = false;
//   bool isDislike = false;
//   bool pressedDislike = false;

//   int getFeedbackItemCount(bool fromReadAllPage, List feedback) {
//     if (fromReadAllPage) return feedback.length;
//     return feedback.length > 2 ? 2 : feedback.length;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       shrinkWrap: true,
//       padding: const EdgeInsets.only(bottom: 30),
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: getFeedbackItemCount(widget.fromReadAllPage, widget.feedback),
//       itemBuilder: (context, index) {
//         return BlocConsumer<LikeCommentCubit, LikeCommentState>(
//           listener: (context, state) {
//             state.maybeWhen(
//               orElse: () {},
//               error: (message) {
//                 Toaster.showErrorTopShortToast(context, message);
//               },
//               loadedLike: () {
//                 // BlocProvider.of<UserFeedbackCubit>(context).userFeedback(id: widget.id);
//                 setState(() {});
//               },
//               loadedDislike: () async {
//                 if (!isLike && isDislike && pressedDislike == false) {
//                   BlocProvider.of<LikeCommentCubit>(context)
//                       .likeComment(feedbackId: widget.feedback[index].id ?? 0, type: 'like');
//                 }
//                 if (pressedDislike == true && !isDislike) {
//                   BlocProvider.of<LikeCommentCubit>(context)
//                       .likeComment(feedbackId: widget.feedback[index].id ?? 0, type: 'dislike');
//                 }

//                 // BlocProvider.of<UserFeedbackCubit>(context).userFeedback(id: widget.id);
//                 // BlocProvider.of<LikeCommentCubit>(context)
//                 //     .likeComment(feedbackId: feedbackDTO.id ?? 0, type: 'like');
//                 // setState(() {});
//                 // await BlocProvider.of<LikeCommentCubit>(context)
//                 //     .likeComment(feedbackId: feedbackDTO.id ?? 0, type: 'dislike');

//                 // await BlocProvider.of<UserFeedbackCubit>(context).userFeedback(id: widget.id);
//                 setState(() {});
//               },
//             );
//           },
//           builder: (context, state) {
//             return Column(
//               children: [
//                 const Gap(14),
//                 ReviewWidgetItem(
//                   feedbackDTO: widget.feedback[index],
//                   onTapDislike: () {
//                     if (!isDislike && !isLike) {
//                       ComplainedBs.show(
//                         context,
//                         feedID: widget.feedback[index].id,
//                         isDislike: true,
//                         isComplainedDislike: (isComplained) {
//                           BlocProvider.of<LikeCommentCubit>(context)
//                               .likeComment(feedbackId: widget.feedback[index].id ?? 0, type: 'dislike');
//                           pressedDislike = true;
//                           setState(() {});
//                         },
//                       );
//                     } else if (isDislike && !isLike) {
//                       BlocProvider.of<LikeCommentCubit>(context)
//                           .dislikeComment(feedbackId: widget.feedback[index].id ?? 0);
//                       pressedDislike = true;
//                       setState(() {});
//                     } else if (!isDislike && isLike) {
//                       ComplainedBs.show(
//                         context,
//                         feedID: widget.feedback[index].id,
//                         isDislike: true,
//                         isComplainedDislike: (isComplained) {
//                           BlocProvider.of<LikeCommentCubit>(context)
//                               .dislikeComment(feedbackId: widget.feedback[index].id ?? 0);
//                           pressedDislike = true;
//                           setState(() {});
//                         },
//                       );
//                     }
//                   },
//                   onTapLike: () {
//                     if (!isLike && !isDislike) {
//                       BlocProvider.of<LikeCommentCubit>(context)
//                           .likeComment(feedbackId: widget.feedback[index].id ?? 0, type: 'like');
//                       pressedDislike = false;
//                       setState(() {});
//                     } else if (isLike && !isDislike) {
//                       BlocProvider.of<LikeCommentCubit>(context)
//                           .dislikeComment(feedbackId: widget.feedback[index].id ?? 0);
//                       pressedDislike = false;
//                       setState(() {});
//                     } else if (!isLike && isDislike) {
//                       BlocProvider.of<LikeCommentCubit>(context)
//                           .dislikeComment(feedbackId: widget.feedback[index].id ?? 0);
//                       pressedDislike = false;
//                       setState(() {});
//                     }
//                   },
//                   activeDislike: false,
//                   activeLike: false,
//                 ),
//                 const Gap(14),
//                 if (widget.fromReadAllPage)
//                   const Divider(
//                     thickness: 0.4,
//                     height: 0.4,
//                     color: AppColors.borderTextField,
//                   )
//                 else if (index == 0)
//                   const Divider(
//                     thickness: 0.4,
//                     height: 0.4,
//                     color: AppColors.borderTextField,
//                   )
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
// }
