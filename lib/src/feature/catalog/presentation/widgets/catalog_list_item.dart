import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/constant/constants.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/main/model/main_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class CatalogListItem extends StatelessWidget {
  final bool isCatalog;
  final CatalogDTO? catalog;
  final SubCatalogDTO? subCatalog;
  final void Function()? onTap;
  const CatalogListItem({
    super.key,
    this.onTap,
    this.catalog,
    this.subCatalog,
    required this.isCatalog,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 16, vertical: isCatalog ? 0 : 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (isCatalog)
                          Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.grey,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                    catalog?.image ?? NOT_FOUND_IMAGE)),
                          ),
                        const Gap(10),
                        Expanded(
                          child: Text(
                            isCatalog
                                ? context.currentLocale.toString() == 'kk'
                                    ? '${catalog?.nameKk}'
                                    : context.currentLocale.toString() == 'en'
                                        ? '${catalog?.nameEn}'
                                        : context.currentLocale.toString() ==
                                                'uz'
                                            ? '${catalog?.nameUz}'
                                            : context.currentLocale
                                                        .toString() ==
                                                    'zh'
                                                ? '${catalog?.nameZh}'
                                                : '${catalog?.name}'
                                : context.currentLocale.toString() == 'kk'
                                    ? '${subCatalog?.nameKk}'
                                    : context.currentLocale.toString() == 'en'
                                        ? '${subCatalog?.nameEn}'
                                        : context.currentLocale.toString() ==
                                                'uz'
                                            ? '${subCatalog?.nameUz}'
                                            : context.currentLocale
                                                        .toString() ==
                                                    'zh'
                                                ? '${subCatalog?.nameZh}'
                                                : '${subCatalog?.name}',
                            // isCatalog ? '${catalog?.name}' : '${subCatalog?.name}',
                            style: AppTextStyles.fs14w500.copyWith(height: 1.2),
                          ),
                        ),
                        const Gap(8)
                      ],
                    ),
                  ),
                  SvgPicture.asset(AssetsConstants.shevron)
                ],
              ),
            ),
          ),
        ),
        // const Gap(12)
      ],
    );
  }
}
