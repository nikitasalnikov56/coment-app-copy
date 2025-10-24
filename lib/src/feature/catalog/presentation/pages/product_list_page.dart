import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/extensions/build_context.dart';
import 'package:coment_app/src/core/presentation/widgets/scroll/pull_to_refresh_widgets.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/search_widget.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
import 'package:coment_app/src/feature/main/bloc/product_list_cubit.dart';
import 'package:coment_app/src/feature/catalog/presentation/widgets/branches_bs.dart';
import 'package:coment_app/src/feature/catalog/presentation/widgets/product_item.dart';
import 'package:coment_app/src/feature/catalog/presentation/widgets/sorting_bs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

@RoutePage()
class ProductListPage extends StatefulWidget implements AutoRouteWrapper {
  const ProductListPage({super.key, required this.subcatalogId, required this.subCatalogTitle});

  final int subcatalogId;
  final String subCatalogTitle;

  @override
  State<ProductListPage> createState() => _ProductListPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(
        create: (context) => ProductListCubit(
          repository: context.repository.mainRepository,
        ),
      ),
    ], child: this);
  }
}

class _ProductListPageState extends State<ProductListPage> {
  final RefreshController _refreshController = RefreshController();

  int selectedSortingIndex = 0;
  late String? selectedSortingTitle = context.localized.newOnesFirst; //newOnesFirst
  int? productQuantity = 0;
  int? filterQuantity = 0;
  List<int> selectedFilterParam = [0, 0];

  @override
  void initState() {
    BlocProvider.of<ProductListCubit>(context).getProductList(subcatalogId: widget.subcatalogId, sort: 'newest');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ///
            /// <--`back button, search bar`-->
            ///
            Row(
              children: [
                IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      context.router.popUntil((route) => route.settings.name == SubcatalogRoute.name);
                    },
                    splashRadius: 21,
                    icon: SvgPicture.asset(AssetsConstants.backButton)),
                Expanded(
                  child: SearchWidget(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.borderColor,
                      ),
                    ),
                    readOnly: true,
                    onTap: () {
                      context.router.push(const AddFeedbackSearchingRoute());
                    },
                  ),
                ),
                const Gap(16)
              ],
            ),

            ///
            /// <--`subcategory title, quantity, filter`-->
            ///
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.subCatalogTitle,
                        style: AppTextStyles.fs16w500.copyWith(height: 1.4),
                      ),
                      const Gap(4),
                      Text(
                        '${context.localized.quantity} ($productQuantity)', //quantity
                        style: AppTextStyles.fs12w500.copyWith(height: 1.2, color: AppColors.greyTextColor2),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      if (filterQuantity != 0)
                        Container(
                          height: 18,
                          width: 18,
                          decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              '$filterQuantity',
                              style: AppTextStyles.fs12w500.copyWith(height: 1.2, color: AppColors.white),
                            ),
                          ),
                        ),
                      const Gap(4),
                      GestureDetector(
                          onTap: () {
                            context.router.push(FilterRoute(
                              countryId: selectedFilterParam[0],
                              cityId: selectedFilterParam[1],
                              selectedFilter: (countryId, cityId) {
                                filterQuantity = getFilterQuantity(countryId, cityId);
                                selectedFilterParam = [countryId, cityId];
                                BlocProvider.of<ProductListCubit>(context).getProductList(
                                  subcatalogId: widget.subcatalogId,
                                  sort: getSortedProductList(selectedSortingIndex),
                                  countryId: countryId,
                                  cityId: cityId,
                                );

                                setState(() {});
                              },
                            ));
                          },
                          child: SvgPicture.asset(AssetsConstants.filter))
                    ],
                  )
                ],
              ),
            ),

            ///
            /// <--`sorting, add feedback`-->
            ///
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 14),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.mainColor), borderRadius: BorderRadius.circular(16)),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          SortingBottomSheet.show(
                            context,
                            index: selectedSortingIndex,
                            selectedSorting: (title, index) {
                              selectedSortingTitle = title;
                              selectedSortingIndex = index;
                              BlocProvider.of<ProductListCubit>(context).getProductList(
                                subcatalogId: widget.subcatalogId,
                                sort: getSortedProductList(selectedSortingIndex),
                              );
                              setState(() {});
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: Row(
                            children: [
                              Text(
                                '$selectedSortingTitle',
                                style: AppTextStyles.fs14w400.copyWith(height: 1.2),
                              ),
                              const Gap(6),
                              SvgPicture.asset(AssetsConstants.shevronDown)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Container(
                    decoration: BoxDecoration(color: AppColors.mainColor, borderRadius: BorderRadius.circular(16)),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          if (context.appBloc.isAuthenticated) {
                            context.router.push(const AddFeedbackSearchingRoute());
                          } else {
                            context.router.push(const RegisterRoute());
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: Row(
                            children: [
                              Text(
                                context.localized.addreview,
                                style: AppTextStyles.fs14w400.copyWith(height: 1.2, color: AppColors.white),
                              ),
                              const Gap(6),
                              SvgPicture.asset(AssetsConstants.add)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ///
            ///  <--`list`-->
            ///
            BlocConsumer<ProductListCubit, ProductListState>(
              listener: (context, state) {
                state.maybeWhen(
                  orElse: () {},
                  loaded: (data) {
                    productQuantity = data.length;
                    setState(() {});
                  },
                );
              },
              builder: (context, state) {
                return state.maybeWhen(
                    orElse: () => const Expanded(child: Center(child: CircularProgressIndicator.adaptive())),
                    loaded: (data) => data.isNotEmpty
                        ? Expanded(
                            child: SmartRefresher(
                              header: const RefreshClassicHeader(),
                              controller: _refreshController,
                              onRefresh: () {
                                BlocProvider.of<ProductListCubit>(context).getProductList(
                                  subcatalogId: widget.subcatalogId,
                                  sort: getSortedProductList(selectedSortingIndex),
                                  countryId: selectedFilterParam[0],
                                  cityId: selectedFilterParam[1],
                                );
                                _refreshController.refreshCompleted();
                              },
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: const EdgeInsets.only(top: 2, left: 16, right: 16),
                                itemCount: data.length,
                                separatorBuilder: (context, index) => const Gap(16),
                                itemBuilder: (context, index) {
                                  return ProductItem(
                                    product: data[index],
                                    onTap: () {
                                      if (data[index].branches == null || (data[index].branches ?? []).isEmpty) {
                                        context.router.push(ProductDetailRoute(productId: data[index].id ?? 0));
                                      } else {
                                        BranchesBottomSheet.show(
                                          context,
                                          index: selectedSortingIndex,
                                        );
                                      }
                                    },
                                    onTapBranch: () {},
                                  );
                                },
                              ),
                            ),
                          )
                        : Expanded(
                            child: SmartRefresher(
                              header: const RefreshClassicHeader(),
                              controller: _refreshController,
                              onRefresh: () {
                                BlocProvider.of<ProductListCubit>(context).getProductList(
                                  subcatalogId: widget.subcatalogId,
                                  sort: getSortedProductList(selectedSortingIndex),
                                  countryId: selectedFilterParam[0],
                                  cityId: selectedFilterParam[1],
                                );
                                _refreshController.refreshCompleted();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 28),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Gap(150),
                                    Text(
                                      '${context.localized.noReviewsYet}?',
                                      style: AppTextStyles.fs22w700.copyWith(height: 1.3),
                                      textAlign: TextAlign.center,
                                    ),
                                    const Gap(12),
                                    Text(
                                      '${context.localized.createYourFirstCard}!', //createYourFirstCard
                                      style: AppTextStyles.fs14w400.copyWith(height: 1.3),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ));
              },
            )
          ],
        ),
      ),
    );
  }

  int getFilterQuantity(int countryId, int cityId) {
    if (countryId != 0 && cityId != 0) {
      return 2;
    } else if (countryId != 0 || cityId != 0) {
      return 1;
    } else {
      return 0;
    }
  }

  String getSortedProductList(int index) {
    return switch (index) {
      0 => 'newest',
      1 => 'oldest',
      2 => 'rating-desc',
      _ => '',
    };
  }
}
