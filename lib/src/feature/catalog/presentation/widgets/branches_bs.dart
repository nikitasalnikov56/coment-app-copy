import 'dart:developer';
import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/presentation/widgets/bottomsheet/custom_drag_handle.dart';
import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class BranchesBottomSheet extends StatefulWidget {
  const BranchesBottomSheet({super.key, this.index});

  final int? index;

  @override
  State<BranchesBottomSheet> createState() => _BranchesBottomSheetState();

  static Future<void> show(BuildContext context, {int? index}) => showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => BranchesBottomSheet(
          index: index,
        ),
      );
}

class _BranchesBottomSheetState extends State<BranchesBottomSheet> {
  int? selectedIndex;
  String? selectedTitle;

  List<String> itemsTitle = ['Филал 1', 'Филал 2', 'Филал 3'];

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

            ///
            /// title and closing icon
            ///
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.localized.select_a_branch,
                    style: AppTextStyles.fs18w700.copyWith(height: 1.35),
                  ),
                  IconButton(
                    onPressed: () {
                      context.router.maybePop();
                    },
                    icon: SvgPicture.asset(
                      AssetsConstants.close,
                      height: 26,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(10),

            ///
            /// list of address in BasketPage
            ///
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemsTitle.length,
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
                            selectedTitle = itemsTitle[index];
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                itemsTitle[index],
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
                  log('$selectedTitle -- $selectedIndex');
                  Navigator.pop(context);
                  // context.router.push(const ProductDetailRoute());
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
      },
    );
  }
}
