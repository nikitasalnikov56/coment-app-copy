import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/presentation/widgets/bottomsheet/custom_drag_handle.dart';
import 'package:coment_app/src/feature/main/model/main_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:gap/gap.dart';

class CountryBs extends StatefulWidget {
  const CountryBs({super.key, this.index, required this.countryDTO, this.selectedCountry});
  final int? index;
  final List<CountryDTO>? countryDTO;
  final Function(int? id, String? title, int? index)? selectedCountry;

  static Future<String?> show(BuildContext context,
      {List<CountryDTO>? countryDTO, Function(int? id, String? title, int? index)? selectedCountry, int? index}) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CountryBs(
        countryDTO: countryDTO,
        selectedCountry: selectedCountry,
        index: index,
      ),
    );
  }

  @override
  State<CountryBs> createState() => _CountryBsState();
}

class _CountryBsState extends State<CountryBs> {
  int? selectedId;
  int? selectedIndex;
  String? selectedTitle;

  @override
  void initState() {
    selectedIndex = widget.index;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.6,
      initialChildSize: 0.5,
      builder: (context, scrollController) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(child: CustomDragHandle()),

            ///
            /// title and closing icon
            ///
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    'Выберите страну',
                    style: AppTextStyles.fs18w700.copyWith(height: 1.35),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: SvgPicture.asset(
                     AssetsConstants.close,
                      height: 26,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(10),

            ///
            /// list
            ///
            ((widget.countryDTO ?? []).isEmpty)
                ? const SizedBox()
                : Expanded(
                    // padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: (widget.countryDTO ?? []).length,
                      separatorBuilder: (context, index) => const Gap(12),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                  if (index == selectedIndex) {
                                    selectedIndex = null;
                                    selectedId = null;
                                    selectedTitle = null;
                                  } else {
                                    selectedIndex = index;
                                    selectedId = widget.countryDTO?[index].id;
                                    selectedTitle = widget.countryDTO?[index].name;
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      (widget.countryDTO ?? [])[index].name,
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
              padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
              child: CustomButton(
                onPressed: () {
                  widget.selectedCountry?.call(selectedId ?? 0, selectedTitle ?? '', selectedIndex);
                  context.router.maybePop();
                },
                style: CustomButtonStyles.mainButtonStyle(context),
                child: const Text('Выбрать', style: AppTextStyles.fs16w600),
              ),
            ),
            const Gap(30),
          ],
        );
      },
    );
  }
}
