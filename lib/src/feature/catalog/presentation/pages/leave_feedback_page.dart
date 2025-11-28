import 'dart:developer';
import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/presentation/widgets/dialog/toaster.dart';
import 'package:coment_app/src/core/presentation/widgets/other/custom_loading_overlay_widget.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
import 'package:coment_app/src/feature/catalog/bloc/leave_feedback_cubit.dart';
import 'package:coment_app/src/feature/catalog/model/feedback_payload.dart';
import 'package:coment_app/src/feature/catalog/presentation/widgets/choose_image_bs.dart';
import 'package:coment_app/src/feature/catalog/widgets/thank_you_bs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';

@RoutePage()
class LeaveFeedbackPage extends StatefulWidget implements AutoRouteWrapper {
  const LeaveFeedbackPage(
      {Key? key, required this.productID, required this.selectedRating})
      : super(key: key);

  final int productID;
  final int selectedRating;

  @override
  State<LeaveFeedbackPage> createState() => _LeaveFeedbackPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(
        create: (context) => LeaveFeedbackCubit(
          repository: context.repository.catalogRepository,
        ),
      ),
    ], child: this);
  }
}

class _LeaveFeedbackPageState extends State<LeaveFeedbackPage> {
  final TextEditingController _controller = TextEditingController();
  int selectedRating = 0;
  bool isLoading = false;
  bool visibleError = false;

  // final List<XFile> _images = [];

  final ImagePicker imagePicker = ImagePicker();
  List<File> imageFileList = [];

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  void initState() {
    selectedRating = widget.selectedRating;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      onPanDown: (details) {
        FocusScope.of(context).unfocus();
      },
      child: LoaderOverlay(
        overlayColor: AppColors.barrierColor,
        overlayWidgetBuilder: (progress) => const CustomLoadingOverlayWidget(),
        child: Scaffold(
          appBar: CustomAppBar(
            title: context.localized.leaveFeedback,
            actions: [
              Container(
                width: 40,
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                ///
                /// icon
                ///
                const Gap(6),
                Image.asset(
                  AssetsConstants.feedbackImg,
                  height: 160,
                  width: 160,
                ),
                const Gap(16),

                ///
                /// Rating stars
                ///
                Text(context.localized.rateThisPlace,
                    style: AppTextStyles.fs20w600.copyWith(height: 1.6)),
                const Gap(10),
                _buildStarRating(),
                const SizedBox(height: 26),

                ///
                /// Write a review
                ///
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {});
                    },
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: context.localized.writeReview,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    maxLines: 4,
                  ),
                ),
                const SizedBox(height: 6),

                // Word Count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (visibleError)
                        Text(
                          context.localized.minFiveWords,
                          style: AppTextStyles.fs12w600
                              .copyWith(color: AppColors.red2),
                        )
                      else
                        Container(),
                      Text(
                          "${countWords(_controller.text)}/15 ${context.localized.words}",
                          style: AppTextStyles.fs12w600
                              .copyWith(color: AppColors.base400)),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // Image Picker and Preview\
                SizedBox(
                  width: double.infinity,
                  child: imageFileList.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CustomButton(
                            height: 52,
                            onPressed: () async {
                              await ChooseImageBottomSheet.show(
                                context,
                                avatar: false,
                                image: (image) {
                                  if (image != null) {
                                    imageFileList.add(image);
                                  }
                                  setState(() {});
                                },
                              );
                              // final limit = 5 - imageFileList!.length;

                              // final minLimit = math.max(0, limit);
                              // if (minLimit == 1) {
                              //   final selectedImage = await imagePicker.pickImage(source: ImageSource.gallery);
                              //   if (selectedImage != null) {
                              //     setState(() {
                              //       imageFileList!.add(selectedImage);
                              //     });
                              //   }
                              // } else if (minLimit > 1) {
                              //   final List<XFile> selectedImages = await imagePicker.pickMultiImage(limit: minLimit);
                              //   if (selectedImages.isNotEmpty) {
                              //     setState(() {
                              //       imageFileList!.addAll(selectedImages);
                              //     });
                              //   }
                              // }
                            },
                            style:
                                CustomButtonStyles.primaryButtonStyle(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.localized.addPhoto, //addPhoto
                                  style: AppTextStyles.fs16w500.copyWith(
                                    color: AppColors.mainColor,
                                  ),
                                ),
                                const Gap(10),
                                const Icon(
                                  Icons.add_circle_outline,
                                  color: AppColors.mainColor,
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 80,
                          child: ListView(
                            padding: const EdgeInsets.only(left: 16),
                            scrollDirection: Axis.horizontal,
                            children: [
                              SizedBox(
                                height: 80,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: imageFileList.length,
                                  scrollDirection: Axis.horizontal,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          left: index == 0 ? 0 : 10.0),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(12)),
                                        child: Stack(
                                          children: [
                                            Image.file(
                                              File(imageFileList[index].path),
                                              height: 80,
                                              width: 80,
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned(
                                              top: 2,
                                              right: 2,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    imageFileList
                                                        .removeAt(index);
                                                  });
                                                },
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                      color: AppColors
                                                          .backgroundInput,
                                                      shape: BoxShape.circle),
                                                  child: SvgPicture.asset(
                                                    AssetsConstants.close,
                                                    height: 20,
                                                    width: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const Gap(8),
                              if (imageFileList.length < 5)
                                Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: InkWell(
                                    onTap: () async {
                                      await ChooseImageBottomSheet.show(
                                        context,
                                        avatar: false,
                                        image: (image) {
                                          if (image != null) {
                                            imageFileList.add(image);
                                          }

                                          setState(() {});
                                        },
                                      );
                                      // final limit = 5 - imageFileList!.length;

                                      // final minLimit = math.max(0, limit);
                                      // if (minLimit == 1) {
                                      //   final selectedImage = await imagePicker.pickImage(source: ImageSource.gallery);
                                      //   if (selectedImage != null) {
                                      //     setState(() {
                                      //       imageFileList!.add(selectedImage);
                                      //     });
                                      //   }
                                      // } else if (minLimit > 1) {
                                      //   final List<XFile> selectedImages =
                                      //       await imagePicker.pickMultiImage(limit: minLimit);
                                      //   if (selectedImages.isNotEmpty) {
                                      //     setState(() {
                                      //       imageFileList!.addAll(selectedImages);
                                      //     });
                                      //   }
                                      // }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppColors.mainColor,
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 28, horizontal: 23.75),
                                        child: SvgPicture.asset(
                                          AssetsConstants.addPurple,
                                          height: 24,
                                          width: 24,
                                          // color: AppColors.darkGrey2Color,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),

                const SizedBox(height: 80),

                ///
                /// submit button
                ///

                BlocListener<LeaveFeedbackCubit, LeaveFeedbackState>(
                  listener: (context, state) {
                    state.maybeWhen(
                      error: (message) {
                        context.loaderOverlay.hide();
                        Toaster.showErrorTopShortToast(context, message);
                      },
                      loading: () {
                        context.loaderOverlay.show();
                      },
                      loaded: () async {
                        context.loaderOverlay.hide();
                        context.router.popUntil(
                          (route) =>
                              route.settings.name == ProductDetailRoute.name,
                        );
                        await Future.delayed(const Duration(seconds: 1));
                        if (context.mounted) ThankYouBs.show(context);
                      },
                      // toxicWarning: () {
                      //   context.loaderOverlay.hide();
                      //   Toaster.showTopShortToast(
                      //     context,
                      //     message:
                      //         'Ваш комментарий содержал недопустимые выражения и был автоматически исправлен. Пожалуйста, соблюдайте правила сообщества.',
                      //   );
                      //   context.router.popUntil(
                      //     (route) =>
                      //         route.settings.name == ProductDetailRoute.name,
                      //   );
                      //   ThankYouBs.show(context);
                      // },
                      // toxicWithAdminReview: () {
                      //   context.loaderOverlay.hide();
                      //   Toaster.showTopShortToast(
                      //     context,
                      //     message:
                      //         'Ваш комментарий отправлен на рассмотрение администратору!',
                      //   );
                      //   context.router.popUntil(
                      //     (route) =>
                      //         route.settings.name == ProductDetailRoute.name,
                      //   );
                      //   ThankYouBs.show(context);
                      // },
                      orElse: () {
                        context.loaderOverlay.hide();
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomButton(
                      onPressed: () async {
                        log(_controller.text, name: 'text');
                        log('${imageFileList.length}', name: 'images');
                        log('$selectedRating', name: 'rating');
                        log('${widget.productID}', name: 'product id');
                        // if (countWords(_controller.text) >= 15) {
                        final comment = _controller.text.trim();
                        if (comment.isEmpty || countWords(comment) < 15) {
                          return;
                        }
                        final FeedbackPayload feedbackPayload = FeedbackPayload(
                          productId: widget.productID,
                          comment: comment,
                          rating: selectedRating,
                        );
                        print('DEBUG: Sending comment = $comment');
                        await BlocProvider.of<LeaveFeedbackCubit>(context)
                            .createFeedback(
                          feedbackPayload: feedbackPayload,
                          image: imageFileList,
                        );
                        // }
                      },
                      style: countWords(_controller.text) >= 15 &&
                              imageFileList.isNotEmpty
                          ? CustomButtonStyles.mainButtonStyle(context)
                          : CustomButtonStyles.greyButtonStyle(context),
                      child: Text(context.localized.leaveFeedback,
                          style: AppTextStyles.fs16w600.copyWith(
                              color: countWords(_controller.text) >= 15 &&
                                      imageFileList.isNotEmpty
                                  ? AppColors.white
                                  : Colors.black)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            if (index == 0 && selectedRating == 1) {
              selectedRating = 0;
            } else {
              selectedRating = index + 1;
            }

            setState(() {});
          },
          // onTap: () => setState(() => _selectedRating = index + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            child: SvgPicture.asset(AssetsConstants.notActiveStar32,
                colorFilter: index < selectedRating
                    ? const ColorFilter.mode(
                        AppColors.starColorYellow, BlendMode.srcIn)
                    : null),
          ),
        );
      }),
    );
  }
}

int countWords(String text) {
  if (text.trim().isEmpty) return 0;
  return text.trim().split(RegExp(r'\s+')).length;
}
