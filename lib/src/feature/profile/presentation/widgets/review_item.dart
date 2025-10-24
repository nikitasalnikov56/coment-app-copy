// import 'package:coment_app/src/core/gen/assets.gen.dart';
// import 'package:coment_app/src/core/theme/resources.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:gap/gap.dart';

// class ReviewItem extends StatefulWidget {
//   final Image imageComp;
//   final String name;
//   final String date;
//   final String review;
//   final int rating;
//   final int likes;
//   final int comments;
//   final int views;

//   const ReviewItem({
//     super.key,
//     required this.imageComp,
//     required this.name,
//     required this.date,
//     required this.review,
//     required this.rating,
//     required this.likes,
//     required this.comments,
//     required this.views,
//   });

//   @override
//   State<ReviewItem> createState() => _ReviewItemState();
// }

// class _ReviewItemState extends State<ReviewItem> {
//   bool _isLiked = false;
//   bool _isDisliked = false;
//   int _likesCount = 0;

//   @override
//   void initState() {
//     super.initState();
//     _likesCount = widget.likes;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 5),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Profile Image
//           ClipRRect(
//             borderRadius: BorderRadius.circular(32),
//             child: SizedBox(
//               height: 50,
//               width: 50,
//               child: widget.imageComp,
//             ),
//           ),
//           const SizedBox(width: 12),
//           // Review Details
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // User Name
//                         Text(widget.name, style: AppTextStyles.fs14w600),
//                         const SizedBox(height: 4),
//                         // Review Date
//                         Text(
//                           widget.date,
//                           style: const TextStyle(color: Color(0xFFA7A7A7), fontSize: 12, fontWeight: FontWeight.w500),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       children: List.generate(
//                         widget.rating,
//                         (index) => const Icon(
//                           Icons.star,
//                           color: Colors.amber,
//                           size: 16,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 8),
//                 // Review Text
//                 Text(
//                   widget.review,
//                   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//                 ),
//                 const Gap(8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         // Likes
//                         Row(
//                           children: [
//                             InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   if (_isLiked) {
//                                     _isLiked = false;
//                                     _likesCount--;
//                                   } else {
//                                     _isLiked = true;
//                                     _isDisliked = false;
//                                     _likesCount++;
//                                   }
//                                 });
//                               },
//                               child: SvgPicture.asset(
//                                 Assets.icons.icLike.path,
//                               ),
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               _likesCount.toString(),
//                               style: const TextStyle(fontSize: 14),
//                             ),
//                             const SizedBox(width: 4),
//                             InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   if (_isDisliked) {
//                                     _isDisliked = false;
//                                     _likesCount++;
//                                   } else {
//                                     _isDisliked = true;
//                                     _isLiked = false;
//                                     _likesCount--;
//                                   }
//                                 });
//                               },
//                               child: SvgPicture.asset(
//                                 Assets.icons.icDislike.path,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(width: 10),
//                         // Comments
//                         Row(
//                           children: [
//                             SvgPicture.asset(Assets.icons.icComment.path),
//                             const SizedBox(width: 4),
//                             Text(
//                               widget.comments.toString(),
//                               style: const TextStyle(fontSize: 14),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         SvgPicture.asset(Assets.icons.icVisibility.path),
//                         const SizedBox(width: 4),
//                         Text(
//                           widget.views.toString(),
//                           style: const TextStyle(fontSize: 14),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
