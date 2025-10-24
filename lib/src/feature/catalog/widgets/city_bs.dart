import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/presentation/widgets/bottomsheet/custom_drag_handle.dart';
import 'package:coment_app/src/feature/main/model/main_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:gap/gap.dart';

class CityBs extends StatefulWidget {
  const CityBs({super.key, this.id, this.selectedCity, this.cityDTO});
  final int? id;
  final List<CityDTO>? cityDTO;
  final Function(int? id, String? title)? selectedCity;

  static Future<String?> show(BuildContext context,
      {List<CityDTO>? cityDTO, Function(int? id, String? title)? selectedCity, int? id}) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CityBs(
        cityDTO: cityDTO,
        selectedCity: selectedCity,
        id: id,
      ),
    );
  }

  @override
  State<CityBs> createState() => _CityBsState();
}

class _CityBsState extends State<CityBs> {
  int? selectedId;
  String? selectedTitle;

  @override
  void initState() {
    selectedId = widget.id;
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
                    'Выберите город',
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
            ((widget.cityDTO ?? []).isEmpty)
                ? const SizedBox()
                : Expanded(
                    // padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: (widget.cityDTO ?? []).length,
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
                                  if (widget.cityDTO?[index].id == selectedId) {
                                    selectedId = null;
                                    selectedTitle = null;
                                  } else {
                                    selectedId = widget.cityDTO?[index].id;
                                    selectedTitle = widget.cityDTO?[index].name;
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
                                      (widget.cityDTO ?? [])[index].name,
                                      style: AppTextStyles.fs14w400.copyWith(color: AppColors.text),
                                    ),
                                    SvgPicture.asset(
                                      selectedId == widget.cityDTO?[index].id
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
                  widget.selectedCity?.call(selectedId ?? 0, selectedTitle ?? '');
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
