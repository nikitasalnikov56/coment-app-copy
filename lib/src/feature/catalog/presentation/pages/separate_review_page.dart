// import 'package:auto_route/auto_route.dart';
// import 'package:coment_app/src/core/gen/assets.gen.dart';
// import 'package:coment_app/src/core/theme/resources.dart';
// import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
// import 'package:coment_app/src/feature/catalog/bloc/user_feedback_cubit.dart';
// import 'package:coment_app/src/feature/catalog/widgets/complained_bs.dart';
// import 'package:coment_app/src/feature/catalog/widgets/floating_review_input.dart';
// import 'package:coment_app/src/feature/catalog/widgets/review_avatar.dart';
// import 'package:flutter/material.dart';
// import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
// import 'package:coment_app/src/feature/catalog/widgets/separate_review_widget_item.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:gap/gap.dart';

// @RoutePage()
// class SeparateReviewPage extends StatefulWidget implements AutoRouteWrapper {
//   final int id;

//   const SeparateReviewPage({
//     Key? key,
//     required this.id,
//   }) : super(key: key);

//   @override
//   State<SeparateReviewPage> createState() => _SeparateReviewPageState();

//   @override
//   Widget wrappedRoute(BuildContext context) {
//     return MultiBlocProvider(providers: [
//       BlocProvider(
//         create: (context) => UserFeedbackCubit(
//           repository: context.repository.catalogRepository,
//         ),
//       ),
//     ], child: this);
//   }
// }

// class _SeparateReviewPageState extends State<SeparateReviewPage> {
//   bool _isLiked = false;
//   bool _isDisliked = false;
//   bool _isReplying = false;
//   int _likesCount = 0;
//   final TextEditingController _replyController = TextEditingController();

//   @override
//   void initState() {
//     BlocProvider.of<UserFeedbackCubit>(context).userFeedback(id: widget.id);
//     super.initState();
//     //_likesCount = widget.likes;
//   }

//   @override
//   void dispose() {
//     _replyController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<UserFeedbackCubit, UserFeedbackState>(
//         listener: (context, state) {
//       state.maybeWhen(
//         orElse: () {},
//         loading: () {},
//         loaded: (mainDTO) {},
//       );
//     }, builder: (context, state) {
//       return state.maybeWhen(
//         loading: () {
//           return Scaffold(
//             appBar: AppBar(),
//             body: const Center(
//               child: SingleChildScrollView(),
//             ),
//           );
//         },
//         orElse: () {
//           return Scaffold(
//             appBar: AppBar(),
//             body: const Center(
//               child: Text("Or Else"),
//             ),
//           );
//         },
//         loaded: (feedbackDTO) {
//           return Scaffold(
//             appBar: CustomAppBar(
//               title: context.localized.feedback,
//               quarterTurns: 0,
//               actions: [
//                 const Gap(16),
//                 InkWell(
//                   onTap: () => _showBottomSheet(context),
//                   child: SvgPicture.asset(Assets.icons.icThreeDots.path),
//                 ),
//                 const Gap(16),
//               ],
//             ),
//             body: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   // Main review content
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 5),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         ReviewAvatar(
//                         imageAva: feedbackDTO.user?.avatar ?? "",
//                           rating: feedbackDTO.rating ?? 1,
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Review header
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       // User Name
//                                       Text("${feedbackDTO.user?.name}",
//                                           style: AppTextStyles.fs14w600),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         "${feedbackDTO.createdAt}",
//                                         style: const TextStyle(
//                                             color: Color(0xFFA7A7A7),
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w500),
//                                       ),
//                                     ],
//                                   ),
//                                   Row(
//                                     children: List.generate(
//                                       feedbackDTO.rating?.toInt() ?? 4,
//                                       (index) => const Icon(
//                                         Icons.star,
//                                         color: Colors.amber,
//                                         size: 16,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 "${feedbackDTO.comment}",
//                                 style: const TextStyle(
//                                     fontSize: 14, fontWeight: FontWeight.w500),
//                               ),
//                               const Gap(10),
//                               feedbackDTO.images != null &&
//                                       feedbackDTO.images!.isNotEmpty
//                                   ? Wrap(
//                                       spacing: 8,
//                                       runSpacing: 8,
//                                       children: feedbackDTO.images!
//                                           .map((imageDTO) => SizedBox(
//                                                 height: 80,
//                                                 width: 80,
//                                                 child: ClipRRect(
//                                                   borderRadius:
//                                                       BorderRadius.circular(12),
//                                                   child: Image.network(
//                                                     imageDTO.image ?? '',
//                                                     fit: BoxFit.cover,
//                                                     errorBuilder: (context,
//                                                             error,
//                                                             stackTrace) =>
//                                                         const Icon(
//                                                             Icons.broken_image),
//                                                   ),
//                                                 ),
//                                               ))
//                                           .toList(),
//                                     )
//                                   : Container(),

//                               const Gap(10),
//                               Row(
//                                 children: [
//                                   Row(
//                                     children: [
//                                       // Likes
//                                       Row(
//                                         children: [
//                                           InkWell(
//                                             onTap: _handleLike,
//                                             child: SvgPicture.asset(
//                                                Assets.icons.icLike.path,
//                                             ),
//                                           ),
//                                           const SizedBox(width: 4),
//                                           Text(
//                                             _likesCount.toString(),
//                                             style:
//                                                 const TextStyle(fontSize: 14),
//                                           ),
//                                           const SizedBox(width: 4),
//                                           InkWell(
//                                             onTap: () {
//                                               _handleDislike.call();
//                                               ComplainedBs.show(context,
//                                                   feedID: widget.id);
//                                             },
//                                             child: SvgPicture.asset(

//                                                    Assets.icons.icDislike.path,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(width: 10),
//                                     ],
//                                   ),
//                                   InkWell(
//                                     onTap: () =>
//                                         setState(() => _isReplying = true),
//                                     child: Text(
//                                       context.localized.answer,
//                                       style: const TextStyle(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w500,
//                                           color: AppColors.greyText),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Divider(indent: 0),
//                   // Nested reviews
//                   Expanded(
//                     child: ListView(
//                       children: [
//                         SeparateReviewWidgetItem(
//                           onReplyPressed: () =>
//                               setState(() => _isReplying = true),
//                           imageAva:
//                               Assets.images.png.imageAvaBob.path,
//                           imageReview:
//                               Image.asset(Assets.images.png.imageReview.path),
//                           name: "Bob Anderson",
//                           date: 'Август 19, 2025',
//                           review:
//                               'A close-knit family - mother, father, adult daughter and teenage son - are relaxing on a large yacht in the Caribbean Sea.',
//                           rating: 5,
//                           likes: 1,
//                           comments: 24,
//                           views: 24,
//                         )
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             floatingActionButton:
//                 _buildFloatingAction("${feedbackDTO.user?.name}"),
//             floatingActionButtonLocation:
//                 FloatingActionButtonLocation.centerFloat,
//           );
//         },
//       );
//     });
//   }

//   Widget _buildFloatingAction(String name) {
//     return _isReplying
//         ? FloatingReviewInput(
//             recipientName: name,
//             onClose: () => setState(() {
//               _isReplying = false;
//               _replyController.clear();
//             }),
//             onSend: (text) {
//               setState(() => _isReplying = false);
//               _replyController.clear();
//             },
//           )
//         : Container();
//   }

//   void _handleLike() {
//     setState(() {
//       if (_isLiked) {
//         _isLiked = false;
//         _likesCount--;
//       } else {
//         _isLiked = true;
//         _isDisliked = false;
//         _likesCount++;
//       }
//     });
//   }

//   void _handleDislike() {
//     setState(() {
//       if (_isDisliked) {
//         _isDisliked = false;
//         _likesCount++;
//       } else {
//         _isDisliked = true;
//         _isLiked = false;
//         _likesCount--;
//       }
//     });
//   }

//   void _showBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       backgroundColor: Colors.transparent,
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(16),
//         ),
//       ),
//       builder: (BuildContext context) {
//         return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     backgroundColor: Colors.white,
//                     foregroundColor: Colors.white,
//                   ),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                     ComplainedBs.show(context, feedID: widget.id);
//                   },
//                   child: Text(
//                     context.localized.complain,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w400,
//                       color: Colors.blue,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               // "Отмена" Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     backgroundColor: Colors.white,
//                     foregroundColor: Colors.white,
//                   ),
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: Text(
//                     context.localized.cancel,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.blue,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
