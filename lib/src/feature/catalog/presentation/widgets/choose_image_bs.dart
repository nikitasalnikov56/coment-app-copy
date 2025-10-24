import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/presentation/widgets/bottomsheet/custom_drag_handle.dart';
import 'package:coment_app/src/core/presentation/widgets/dialog/toaster.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class ChooseImageBottomSheet extends StatefulWidget {
  final bool avatar;
  final Function(File?) image;

  const ChooseImageBottomSheet({
    super.key,
    required this.image,
    this.avatar = true,
  });

  static Future show(
    BuildContext context, {
    required Function(File?) image,
    bool? avatar,
  }) async =>
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        builder: (context) => ChooseImageBottomSheet(
          image: image,
          avatar: avatar ?? true,
          // salary: salary,
          // minSalary: minSalary,
          // maxSalary: maxSalary,
        ),
      );

  @override
  State<ChooseImageBottomSheet> createState() => _ChooseImageBottomSheetState();
}

class _ChooseImageBottomSheetState extends State<ChooseImageBottomSheet> {
  @override
  void initState() {
    super.initState();
  }

  File? _imageCamera;
  File? _imageGalery;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(child: CustomDragHandle()),

            ///
            /// title and closing icon
            ///
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.localized.selectPhoto,
                    style: AppTextStyles.fs18w700.copyWith(height: 1.35),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: SvgPicture.asset(
                      AssetsConstants.close,
                      height: 26,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),

            ///
            /// Camera, gallery
            ///
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 107,
                      decoration: const BoxDecoration(
                          color: AppColors.btnGrey, borderRadius: BorderRadius.all(Radius.circular(12))),
                      child: Material(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            try {
                              final imgCamera = await _imagePicker.pickImage(source: ImageSource.camera);
                              if (imgCamera != null) {
                                if (widget.avatar) {
                                  final File croppedFile = File(imgCamera.path);
                                  setState(() {
                                    _imageCamera = croppedFile;
                                  });
                                } else {
                                  final File croppedFile = File(imgCamera.path);
                                  setState(() {
                                    _imageCamera = croppedFile;
                                  });
                                }
                              }
                            } catch (e) {
                              debugPrint('Failed to pick image: $e');
                              if (!context.mounted) return;
                              Toaster.showErrorTopShortToast(
                                context,
                                'Failed to pick image: $e',
                              );
                            } finally {
                              if (context.mounted) {
                                widget.image.call(_imageCamera);
                                context.router.maybePop();
                              }
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(AssetsConstants.camera),
                              const Gap(8),
                              Text(
                                context.localized.camera,
                                style: AppTextStyles.fs14w500.copyWith(color: AppColors.mainColor),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(11),
                  Expanded(
                    child: Container(
                      height: 107,
                      decoration: const BoxDecoration(
                          color: AppColors.btnGrey, borderRadius: BorderRadius.all(Radius.circular(12))),
                      child: Material(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            try {
                              final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);

                              if (pickedFile != null) {
                                if (widget.avatar) {
                                  final File croppedFile = File(pickedFile.path);
                                  setState(() {
                                    _imageGalery = croppedFile;
                                  });
                                } else {
                                  final File croppedFile = File(pickedFile.path);
                                  setState(() {
                                    _imageGalery = croppedFile;
                                  });
                                }
                              }
                            } catch (e) {
                              debugPrint('Failed to pick image: $e');
                              if (!context.mounted) return;
                              Toaster.showErrorTopShortToast(
                                context,
                                'Failed to pick image: $e',
                              );
                            } finally {
                              if (context.mounted) {
                                widget.image.call(_imageGalery);
                                context.router.maybePop();
                              }
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(AssetsConstants.addPurple),
                              const Gap(8),
                              Text(
                                context.localized.selectFromGallery,
                                style: AppTextStyles.fs14w500.copyWith(color: AppColors.mainColor),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(50),
          ],
        );
      },
    );
  }
}
