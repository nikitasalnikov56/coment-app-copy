import 'dart:developer';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/presentation/widgets/bottomsheet/custom_drag_handle.dart';
import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class SortingBottomSheet extends StatefulWidget {
  const SortingBottomSheet({super.key, this.selectedSorting, this.index});

  final Function(String title, int index)? selectedSorting;
  final int? index;

  @override
  State<SortingBottomSheet> createState() => _SortingBottomSheetState();

  static Future<void> show(BuildContext context, {Function(String title, int index)? selectedSorting, int? index}) =>
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SortingBottomSheet(
          selectedSorting: selectedSorting,
          index: index,
        ),
      );
}

class _SortingBottomSheetState extends State<SortingBottomSheet> {
  int? selectedIndex;
  String? selectedTitle;

  late final List<String> sortingTitle = [
    (context.localized.newOnesFirst),
    (context.localized.oldOnesFirst),
    (context.localized.highRating)
  ]; // highRating oldOnesFirst

  @override
  void initState() {
    selectedIndex = widget.index;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(child: CustomDragHandle()),

            const Gap(10),

            ///
            /// list of address in BasketPage
            ///
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortingTitle.length,
                separatorBuilder: (context, index) => const Gap(12),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.muteGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                            selectedTitle = sortingTitle[index];
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                sortingTitle[index],
                                style: AppTextStyles.fs14w400.copyWith(color: AppColors.text),
                              ),
                              SvgPicture.asset(
                                selectedIndex == index
                                    ? AssetsConstants.icRadioBtnActive
                                    : AssetsConstants.icRadioBtn,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            ///
            /// button
            ///
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
              child: CustomButton(
                onPressed: () {
                  widget.selectedSorting?.call(selectedTitle ?? '', selectedIndex ?? -1);
                  log('$selectedTitle -- $selectedIndex');
                  Navigator.of(context).pop();
                },
                style: CustomButtonStyles.mainButtonStyle(context),
                child: Text(
                  context.localized.choose,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const Gap(30),
          ],
        );
        // return AnimatedPadding(
        //   duration: const Duration(milliseconds: 200),
        //   padding: EdgeInsets.only(bottom: keyboardHeight),
        //   child: DraggableScrollableSheet(
        //     expand: false,
        //     // maxChildSize: 0.95,
        //     minChildSize: 0.4,
        //     initialChildSize: 0.4,
        //     builder: (context, scrollController) => SingleChildScrollView(
        //       controller: scrollController,
        //       child: Column(
        //         mainAxisSize: MainAxisSize.min,
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           const Align(child: CustomDragHandle()),

        //           ///
        //           /// title and closing icon
        //           ///
        //           Padding(
        //             padding: const EdgeInsets.only(left: 16, right: 10),
        //             child: Row(
        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //               children: [
        //                 Text(
        //                   'Выберите язык',
        //                   style: AppTextStyles.fs18w700.copyWith(height: 1.35),
        //                 ),
        //                 IconButton(
        //                   onPressed: () {
        //                     context.router.maybePop();
        //                   },
        //                   icon: SvgPicture.asset(
        //                     Assets.icons.close.path,
        //                     height: 26,
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ),
        //           const Gap(10),

        //           ///
        //           /// list of address in BasketPage
        //           ///
        //           Padding(
        //             padding: const EdgeInsets.symmetric(horizontal: 16),
        //             child: ListView.separated(
        //               shrinkWrap: true,
        //               physics: const NeverScrollableScrollPhysics(),
        //               itemCount: sortingTitle.length,
        //               separatorBuilder: (context, index) => const Gap(12),
        //               padding: EdgeInsets.zero,
        //               itemBuilder: (context, index) {
        //                 return Container(
        //                   decoration: BoxDecoration(
        //                     color: AppColors.muteGrey,
        //                     borderRadius: BorderRadius.circular(12),
        //                   ),
        //                   child: Material(
        //                     color: Colors.transparent,
        //                     borderRadius: BorderRadius.circular(12),
        //                     child: InkWell(
        //                       onTap: () {
        //                         setState(() {
        //                           selectedIndex = index;
        //                           selectedTitle = sortingTitle[index];
        //                         });
        //                       },
        //                       borderRadius: BorderRadius.circular(12),
        //                       child: Padding(
        //                         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        //                         child: Row(
        //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                           children: [
        //                             Text(
        //                               sortingTitle[index],
        //                               style: AppTextStyles.fs14w400.copyWith(color: AppColors.text),
        //                             ),
        //                             SvgPicture.asset(
        //                               selectedIndex == index
        //                                   ? Assets.icons.icRadioBtnActive.path
        //                                   : Assets.icons.icRadioBtn.path,
        //                             ),
        //                           ],
        //                         ),
        //                       ),
        //                     ),
        //                   ),
        //                 );
        //               },
        //             ),
        //           ),

        //           ///
        //           /// button
        //           ///
        //           Padding(
        //             padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
        //             child: CustomButton(
        //               onPressed: () {
        //                 widget.selectedSorting?.call(selectedTitle ?? '', selectedIndex ?? -1);
        //                 log('$selectedTitle -- $selectedIndex');
        //                 Navigator.of(context).pop();
        //               },
        //               style: CustomButtonStyles.mainButtonStyle(context),
        //               child: const Text(
        //                 'Выбрать',
        //                 style: TextStyle(
        //                   fontSize: 16,
        //                   fontWeight: FontWeight.w600,
        //                 ),
        //               ),
        //             ),
        //           ),

        //           const Gap(10),
        //         ],
        //       ),
        //     ),
        //   ),
        // );
      },
    );
  }
}
