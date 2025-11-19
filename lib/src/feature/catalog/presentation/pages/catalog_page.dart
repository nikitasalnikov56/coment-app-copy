import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/constant/constants.dart';
import 'package:coment_app/src/core/presentation/widgets/scroll/pull_to_refresh_widgets.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
import 'package:coment_app/src/feature/catalog/presentation/widgets/catalog_grid_items.dart';
import 'package:coment_app/src/feature/catalog/presentation/widgets/catalog_list_item.dart';
import 'package:coment_app/src/feature/main/bloc/dictionary_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

@RoutePage()
class CatalogPage extends StatefulWidget implements AutoRouteWrapper {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(
        create: (context) => DictionaryCubit(
          repository: context.repository.mainRepository,
        ),
      ),
    ], child: this);
  }
}

class _CatalogPageState extends State<CatalogPage> with SingleTickerProviderStateMixin {
  final RefreshController _refreshController = RefreshController();
  bool isGridView = true;
  @override
  void initState() {
    super.initState();
    BlocProvider.of<DictionaryCubit>(context).getDictionary();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DictionaryCubit, DictionaryState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          loading: () {},
          loaded: (mainDTO) {},
        );
      },
      builder: (context, state) {
        return state.maybeWhen(
            orElse: () => Scaffold(
                  appBar: CustomAppBar(
                    isBackButton: false,
                    title: context.localized.catalog,
                    actions: [
                      GestureDetector(
                          onTap: () {
                            isGridView = false;
                            setState(() {});
                          },
                          child: SvgPicture.asset(
                              isGridView ? AssetsConstants.listInactive : AssetsConstants.listActive)),
                      const Gap(6),
                      GestureDetector(
                          onTap: () {
                            isGridView = true;
                            setState(() {});
                          },
                          child: SvgPicture.asset(
                              isGridView ?AssetsConstants.gridActive : AssetsConstants.gridInactive)),
                      const Gap(16)
                    ],
                  ),
                  body: const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
            loaded: (mainDTO) => Scaffold(
                appBar: CustomAppBar(
                  isBackButton: false,
                  title: context.localized.catalog,
                  actions: [
                    GestureDetector(
                        onTap: () {
                          isGridView = false;
                          setState(() {});
                        },
                        child: SvgPicture.asset(
                            isGridView ? AssetsConstants.listInactive : AssetsConstants.listActive)),
                    const Gap(6),
                    GestureDetector(
                        onTap: () {
                          isGridView = true;
                          setState(() {});
                        },
                        child: SvgPicture.asset(
                            isGridView ? AssetsConstants.gridActive : AssetsConstants.gridInactive)),
                    const Gap(16)
                  ],
                ),
                body: SmartRefresher(
                  header: const RefreshClassicHeader(),
                  controller: _refreshController,
                  onRefresh: () {
                    BlocProvider.of<DictionaryCubit>(context).getDictionary();
                    _refreshController.refreshCompleted();
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ///
                        /// grid view catalog
                        ///
                        if (isGridView)
                          Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16, top: 14),
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: (MediaQuery.of(context).size.width * 0.375) / 130,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 18,
                              ),
                              itemCount: mainDTO.catalog?.length,
                              itemBuilder: (context, index) {
                                // print('Images: ${mainDTO.catalog?[index].image?.length}');
                                return CatalogGridItem(
                                    title: context.currentLocale.toString() == 'kk'
                                        ? '${mainDTO.catalog?[index].nameKk}'
                                        : context.currentLocale.toString() == 'en'
                                            ? '${mainDTO.catalog?[index].nameEn}'
                                            : context.currentLocale.toString() == 'uz'
                                                ? '${mainDTO.catalog?[index].nameUz}'
                                                : '${mainDTO.catalog?[index].name}',
                                    index: index,
                                    image: mainDTO.catalog?[index].image ?? NOT_FOUND_IMAGE,
                                    onTap: () {
                                      log('${context.currentLocale}');
                                      context.router.push(SubcatalogRoute(
                                          title: context.currentLocale.toString() == 'kk'
                                              ? '${mainDTO.catalog?[index].nameKk}'
                                              : context.currentLocale.toString() == 'en'
                                                  ? '${mainDTO.catalog?[index].nameEn}'
                                                  : context.currentLocale.toString() == 'uz'
                                                      ? '${mainDTO.catalog?[index].nameUz}'
                                                      : '${mainDTO.catalog?[index].name}',
                                          catalogId: mainDTO.catalog?[index].id ?? 0));
                                    });
                              },
                            ),
                          )

                        ///
                        /// list view catalog
                        ///
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(bottom: 12),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: (mainDTO.catalog ?? []).length,
                            separatorBuilder: (context, index) => const Gap(12),
                            itemBuilder: (context, index) {
                              return CatalogListItem(
                                catalog: (mainDTO.catalog ?? [])[index],
                                isCatalog: true,
                                onTap: () {
                                  context.router.push(SubcatalogRoute(
                                      title: context.currentLocale.toString() == 'kk'
                                          ? '${mainDTO.catalog?[index].nameKk}'
                                          : context.currentLocale.toString() == 'en'
                                              ? '${mainDTO.catalog?[index].nameEn}'
                                              : context.currentLocale.toString() == 'uz'
                                                  ? '${mainDTO.catalog?[index].nameUz}'
                                                  : '${mainDTO.catalog?[index].name}',
                                      catalogId: mainDTO.catalog?[index].id ?? 0));
                                },
                              );
                            },
                          )
                      ],
                    ),
                  ),
                )));
      },
    );
  }
}
