// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:io';

// import 'package:coment_app/src/core/gen/assets.gen.dart';
// import 'package:coment_app/src/core/theme/resources.dart';
// import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
// import 'package:coment_app/src/feature/catalog/widgets/imag_picker_bs.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:image_picker/image_picker.dart';

// class ImagePickerWidget extends StatefulWidget {
//   final List<File>? images;

//   ImagePickerWidget({super.key, this.images});

//   @override
//   State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
// }

// class _ImagePickerWidgetState extends State<ImagePickerWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       child: widget.images.isEmpty
//           ? SizedBox(
//               height: 52,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   foregroundColor: AppColors.mainColor,
//                   side: const BorderSide(color: AppColors.mainColor, width: 2),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//                 onPressed: () {
//                   _showImagePicker();
//                 },
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       context.localized.add_a_photo,
//                       style: const TextStyle(
//                         color: AppColors.mainColor,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     SvgPicture.asset(Assets.icons.icPutGalery.path),
//                   ],
//                 ),
//               ),
//             )
//           : SizedBox(
//               height: 89,
//               width: 80,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: widget.images.length + 1,
//                 itemBuilder: (context, index) {
//                   if (index == widget.images.length) {
//                     ///
//                     ///Add Photo Button
//                     ///
//                     return GestureDetector(
//                       onTap: _showImagePicker,
//                       child: Padding(
//                         padding: const EdgeInsets.only(left: 11, right: 11, top: 9, bottom: 9),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(color: AppColors.mainColor),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(20),
//                             child: SvgPicture.asset(Assets.icons.icPutGalery.path),
//                           ),
//                         ),
//                       ),
//                     );
//                   }

//                   ///
//                   /// Image Preview
//                   ///

//                   return Stack(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: Image.file(
//                             File(widget.images[index].path),
//                             width: 70,
//                             height: 70,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         top: 1,
//                         right: 8,
//                         child: GestureDetector(
//                           onTap: () => setState(() => widget.images.removeAt(index)),
//                           child: const CircleAvatar(
//                             radius: 12,
//                             backgroundColor: AppColors.greyText,
//                             child: Icon(Icons.close, size: 16, color: AppColors.greyTextColor2),
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//                 separatorBuilder: (_, __) => const SizedBox(width: 8),
//               ),
//             ),
//     );
//   }

//   void _showImagePicker() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         return ImagePickerBottomSheet(
//           onImagePicked: (source) {
//             _pickImage(source);
//           },
//         );
//       },
//     );
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final image = await ImagePicker().pickImage(source: source);
//       if (image != null) {
//         setState(() => widget.images.add(File(image.path)));
//       }
//     } on PlatformException catch (e) {
//       debugPrint("Failed to pick image: $e");
//     } finally {
//       Navigator.pop(context);
//     }
//   }
// }
