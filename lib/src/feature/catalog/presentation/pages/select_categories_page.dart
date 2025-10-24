import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/presentation/widgets/scroll/pull_to_refresh_widgets.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
import 'package:coment_app/src/feature/catalog/model/create_product_model.dart';
import 'package:coment_app/src/feature/catalog/presentation/widgets/catalog_list_item.dart';
import 'package:coment_app/src/feature/main/bloc/dictionary_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

@RoutePage()
class SelectCategoriesPage extends StatefulWidget implements AutoRouteWrapper {
  const SelectCategoriesPage({super.key});

  @override
  State<SelectCategoriesPage> createState() => _SelectCategoriesPageState();

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

class _SelectCategoriesPageState extends State<SelectCategoriesPage> {
  final TextEditingController searchController = TextEditingController();
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<DictionaryCubit>(context).getDictionary();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateProductModel>(builder: (context, value, child) {
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
                body: SafeArea(
                    child: Column(
              children: [
                ///
                /// <--`back button, search bar`-->
                ///
                _headerSearch(),

                const Expanded(
                  child: Text('error'),
                )
              ],
            ))),
            loading: () => Scaffold(
                body: SafeArea(
                    child: Column(
              children: [
                ///
                /// <--`back button, search bar`-->
                ///
                _headerSearch(),

                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                )
              ],
            ))),
            loaded: (mainDTO) => Scaffold(
              body: SafeArea(
                  child: Column(
                children: [
                  ///
                  /// <--`back button, search bar`-->
                  ///
                  _headerSearch(),

                  ///
                  /// <--`Catalog list`-->
                  ///
                  Expanded(
                    child: SmartRefresher(
                      header: const RefreshClassicHeader(),
                      controller: _refreshController,
                      onRefresh: () {
                        BlocProvider.of<DictionaryCubit>(context)
                            .getDictionary();
                        _refreshController.refreshCompleted();
                      },
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: 12, top: 12),
                        itemCount: (mainDTO.catalog ?? []).length,
                        separatorBuilder: (context, index) => const Gap(12),
                        itemBuilder: (context, index) {
                          return CatalogListItem(
                            catalog: (mainDTO.catalog ?? [])[index],
                            isCatalog: true,
                            onTap: () {
                              if (value.categoryId !=
                                  (mainDTO.catalog ?? [])[index].id) {
                                value.subCategoryId = null;
                                value.subCategoryTitle = null;
                                value.productName = null;
                                value.address = null;
                                value.phoneNumber = null;
                                value.link = null;
                                value.countryId = null;
                                value.countryTitle = null;
                                value.cityId = null;
                                value.cityTitle = null;
                                value.productImages = null;
                                value.feedbackImages = null;
                                value.rating = null;
                                value.feedbackText = null;
                                value.categoryId =
                                    (mainDTO.catalog ?? [])[index].id;
                                value.categoryTitle =
                                    (mainDTO.catalog ?? [])[index].name;
                                context.router.push(LeaveFeedbackDetailRoute(
                                    value: value,
                                    countryDTO: mainDTO.country ?? [],
                                    categoryTitle:
                                        (mainDTO.catalog ?? [])[index].name,
                                    categoryId:
                                        (mainDTO.catalog ?? [])[index].id));
                              } else {
                                value.categoryId =
                                    (mainDTO.catalog ?? [])[index].id;
                                value.categoryTitle =
                                    (mainDTO.catalog ?? [])[index].name;
                                context.router.push(LeaveFeedbackDetailRoute(
                                    value: value,
                                    countryDTO: mainDTO.country ?? [],
                                    categoryTitle:
                                        (mainDTO.catalog ?? [])[index].name,
                                    categoryId:
                                        (mainDTO.catalog ?? [])[index].id));
                              }
                            },
                          );
                        },
                      ),
                    ),
                  )
                ],
              )),
            ),
          );
        },
      );
    });
  }

  Widget _headerSearch() {
    return Row(
      children: [
        IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              context.router.maybePop();
            },
            splashRadius: 21,
            icon: SvgPicture.asset(AssetsConstants.backButton)),
      ],
    );
  }
}

List<String> catalogImages = [
  AssetsConstants.image,
  AssetsConstants.image23,
  AssetsConstants.image4,
 AssetsConstants.image3,
  AssetsConstants.image2,
  AssetsConstants.image5,
  AssetsConstants.image6,
  AssetsConstants.image7,
  AssetsConstants.image45,
  AssetsConstants.image17,
  AssetsConstants.image8,
  AssetsConstants.image18,
  AssetsConstants.image19,
];

List<Map<String, dynamic>> catalogTitle = [
  {
    'category': 'Образование',
    'subCategorys': ["Банки", "Брокеры", "Страховые компании", "Обменники"],
  },
  {
    'category': 'Торговля и развлечения',
    'subCategorys': ["Банки", "Брокеры", "Страховые компании", "Обменники"],
  },
  {
    'category': 'Гостиницы и общественное питание',
    'subCategorys': ["Банки", "Брокеры", "Страховые компании", "Обменники"],
  },
  {
    'category': 'Недвижимость и юридические услуги',
    'subCategorys': ["Банки", "Брокеры", "Страховые компании", "Обменники"],
  },
  {
    'category': 'Финансы',
    'subCategorys': ["Банки", "Брокеры", "Страховые компании", "Обменники"],
  },
  {
    'category': 'Автомобили',
    'subCategorys': ["Банки", "Брокеры", "Страховые компании", "Обменники"],
  },
  {
    'category': 'Медицина',
    'subCategorys': ["Банки", "Брокеры", "Страховые компании", "Обменники"],
  },
  {
    'category': 'Техника',
    'subCategorys': ["Банки", "Брокеры", "Страховые компании", "Обменники"],
  },
  {
    'category': 'Производительность',
    'subCategorys': ["Банки", "Брокеры", "Страховые компании", "Обменники"],
  },
  {
    'category': 'Красота и ювелирные украшения',
    'subCategorys': ["Банки", "Брокеры", "Страховые компании", "Обменники"],
  },
  {
    'category': 'Услуги',
    'subCategorys': ["Банки", "Брокеры", "Страховые компании", "Обменники"],
  },
  {
    'category': 'Опросы',
    'subCategorys': ["Банки", "Брокеры", "Страховые компании", "Обменники"],
  },
  {
    'category': 'Вакансии',
    'subCategorys': ["Банки", "Брокеры", "Страховые компании", "Обменники"],
  },
];
