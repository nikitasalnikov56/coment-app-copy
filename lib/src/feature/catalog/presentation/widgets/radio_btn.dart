// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';

// import 'package:coment_app/src/core/theme/resources.dart';
// import 'package:coment_app/src/feature/app/router/app_router.dart';

// class RadioBtn extends StatelessWidget {
//   final String subCategory;
//   final String category;
//   final String groupValue;
//   final ValueChanged<String> onChanged;

//   const RadioBtn({
//     Key? key,
//     required this.subCategory,
//     required this.category,
//     required this.groupValue,
//     required this.onChanged,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final isSelected = subCategory == groupValue;

//     return InkWell(
//       onTap: () {
//         onChanged(subCategory);
//         context.router.push(LeaveFeedbackDetailRoute(category: category, subCategory: subCategory));
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               subCategory,
//               style: TextStyle(
//                 fontSize: 14.0,
//                 fontWeight: FontWeight.w500,
//                 color: isSelected ? Colors.black : Colors.grey.shade700,
//               ),
//             ),
//             Container(
//               height: 24,
//               width: 24,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: isSelected ? AppColors.mainColor : Colors.grey,
//                   width: 2.0,
//                 ),
//                 color: isSelected ? AppColors.mainColor : Colors.transparent,
//               ),
//               child: isSelected
//                   ? const Icon(
//                       Icons.check,
//                       size: 16.0,
//                       color: Colors.white,
//                     )
//                   : null,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
