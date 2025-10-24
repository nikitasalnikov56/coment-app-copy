import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/presentation/widgets/bottomsheet/custom_drag_handle.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/main/bloc/subcatalog_cubit.dart';
import 'package:coment_app/src/feature/main/model/main_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:gap/gap.dart';

class SubCategoryBs extends StatefulWidget {
  const SubCategoryBs(
      {super.key, this.subCatalogList, this.selectedSubCatalog, this.addNewSubcategory, required this.index});
  final List<SubCatalogDTO>? subCatalogList;
  final int? index;
  final Function(int? id, String? title, int? index)? selectedSubCatalog;
  final Function(bool isAdd)? addNewSubcategory;

  @override
  State<SubCategoryBs> createState() => _SubCategoryBsState();

  static Future<String?> show(BuildContext context,
      {List<SubCatalogDTO>? subCatalogList,
      int? index,
      Function(int? id, String? title, int? index)? selectedSubCatalog,
      Function(bool isAdd)? addNewSubcategory}) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SubcatalogCubit(
              repository: context.repository.mainRepository,
            ),
          ),
        ],
        child: SubCategoryBs(
          subCatalogList: subCatalogList,
          index: index,
          selectedSubCatalog: selectedSubCatalog,
          addNewSubcategory: addNewSubcategory,
        ),
      ),
    );
  }
}

class _SubCategoryBsState extends State<SubCategoryBs> {
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
      initialChildSize: (widget.subCatalogList ?? []).isEmpty ? 0.3 : 0.56,
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
                    'Выбрать подкатегорию',
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
            ((widget.subCatalogList ?? []).isEmpty)
                ? const SizedBox()
                : Expanded(
                    // padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: (widget.subCatalogList ?? []).length,
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
                                    widget.selectedSubCatalog?.call(null, null, null);
                                    widget.addNewSubcategory?.call(false);
                                    context.router.maybePop();
                                  } else {
                                    selectedIndex = index;
                                    selectedId = widget.subCatalogList?[index].id;
                                    selectedTitle = widget.subCatalogList?[index].name;

                                    widget.selectedSubCatalog
                                        ?.call(selectedId ?? 0, selectedTitle ?? '', selectedIndex);
                                    widget.addNewSubcategory?.call(false);
                                    context.router.maybePop();
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
                                      (widget.subCatalogList ?? [])[index].name,
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
                  widget.selectedSubCatalog?.call(null, null, null);
                  widget.addNewSubcategory?.call(true);
                  context.router.maybePop();
                },
                style: CustomButtonStyles.mainButtonStyle(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(AssetsConstants.icAdd),
                    const Gap(10),
                    const Text('Добавить подкатегорию', style: AppTextStyles.fs16w600),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
              child: Text(
                "Если не нашли нужную подкатегорию, добавьте её самостоятельно.",
                style: AppTextStyles.fs14w500.copyWith(color: const Color(0xff888888)),
              ),
            ),
            const Gap(30),
          ],
        );
      },
    );
  }
}
