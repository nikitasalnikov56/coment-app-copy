import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  final Function(ImageSource) onImagePicked;

  const ImagePickerBottomSheet({Key? key, required this.onImagePicked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: SizedBox(
              width: 40,
              height: 5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                ///
                /// Title and close button
                /// 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.localized.select_a_photo,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.fs18w700,
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.kF5F6F7,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        height: 26,
                        width: 26,
                        child: SvgPicture.asset(AssetsConstants.notX),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                ///
                /// Camera and gallery buttons
                /// 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ///
                      /// Camera button
                      /// 
                      SizedBox(
                        width: 166,
                        height: 107,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.grey,
                            foregroundColor: AppColors.mainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                SvgPicture.asset(AssetsConstants.icPutCamera),
                                const Gap(8),
                                 Expanded(
                                   child: Text(
                                    context.localized.take_a_photo,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.fs14w500,
                                                                   ),
                                 ),
                              ],
                            ),
                          ),
                          onPressed: () {
                            
                            onImagePicked(ImageSource.camera);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      ///
                      /// Gallery button
                      /// 
                      SizedBox(
                        width: 166,
                        height: 107,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.grey,
                            foregroundColor: AppColors.mainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                SvgPicture.asset(AssetsConstants.icPutGalery),
                                const Gap(8),
                                 Text(
                                  context.localized.gallery,
                                  style: AppTextStyles.fs14w500,
                                ),
                              ],
                            ),
                          ),
                          onPressed: () {
                            onImagePicked(ImageSource.gallery);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
