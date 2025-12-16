// lib/src/feature/profile/presentation/pages/load_documents_page.dart
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/presentation/widgets/dialog/toaster.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

@RoutePage()
class LoadDocumentsPage extends StatefulWidget {
  const LoadDocumentsPage({super.key});

  @override
  State<LoadDocumentsPage> createState() => _LoadDocumentsPageState();
}

class _LoadDocumentsPageState extends State<LoadDocumentsPage> {
  @override
  initState() {
    super.initState();
  }

  File? _imageCamera;
  File? _imageGalery;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: context.localized.loadDocuments,
        shape: const Border(
          bottom: BorderSide(
            color: AppColors.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
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
                        color: AppColors.btnGrey,
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    child: Material(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          try {
                            final imgCamera = await _imagePicker.pickImage(
                                source: ImageSource.camera);
                            if (imgCamera != null) {
                              // if (widget.avatar) {
                              //   final File croppedFile = File(imgCamera.path);
                              //   setState(() {
                              //     _imageCamera = croppedFile;
                              //   });
                              // } else {
                              //   final File croppedFile = File(imgCamera.path);
                              //   setState(() {
                              //     _imageCamera = croppedFile;
                              //   });
                              // }
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
                              // widget.image.call(_imageCamera);
                              // context.router.maybePop();
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
                              style: AppTextStyles.fs14w500
                                  .copyWith(color: AppColors.mainColor),
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
                        color: AppColors.btnGrey,
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    child: Material(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          try {
                            final pickedFile = await _imagePicker.pickImage(
                                source: ImageSource.gallery);
        
                            if (pickedFile != null) {
                              // if (widget.avatar) {
                              //   final File croppedFile = File(pickedFile.path);
                              //   setState(() {
                              //     _imageGalery = croppedFile;
                              //   });
                              // } else {
                              //   final File croppedFile = File(pickedFile.path);
                              //   setState(() {
                              //     _imageGalery = croppedFile;
                              //   });
                              // }
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
                              // widget.image.call(_imageGalery);
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
                              style: AppTextStyles.fs14w500
                                  .copyWith(color: AppColors.mainColor),
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
        ]),
      ),
    );
  }
}
