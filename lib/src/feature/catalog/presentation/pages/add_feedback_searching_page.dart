import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/extensions/build_context.dart';
import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/presentation/widgets/scroll/pull_to_refresh_widgets.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/search_widget.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
import 'package:coment_app/src/feature/catalog/bloc/search_product_list_cubit.dart';
import 'package:coment_app/src/feature/catalog/model/create_product_model.dart';
import 'package:coment_app/src/feature/catalog/presentation/widgets/branches_bs.dart';
import 'package:coment_app/src/feature/catalog/presentation/widgets/product_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

@RoutePage()
class AddFeedbackSearchingPage extends StatefulWidget implements AutoRouteWrapper {
  const AddFeedbackSearchingPage({super.key});

  @override
  State<AddFeedbackSearchingPage> createState() => _AddFeedbackSearchingPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(create: (context) => SearchProductListCubit(repository: context.repository.catalogRepository))
    ], child: this);
  }
}

class _AddFeedbackSearchingPageState extends State<AddFeedbackSearchingPage> {
  bool initialBackground = true;
  final TextEditingController searchController = TextEditingController();
  final RefreshController _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CreateProductModel(),
      child: Builder(
        builder: (context) {
          return GestureDetector(
            onPanDown: (details) {
              FocusScope.of(context).unfocus();
            },
            child: BlocConsumer<SearchProductListCubit, SearchProductListState>(
              listener: (context, state) {},
              builder: (context, state) {
                return Scaffold(
                  body: SafeArea(
                    child: Column(children: [
                      ///
                      /// <--`back button, search bar`-->
                      ///
                      _headerSearch(),

                      ///
                      /// <--`initial background`-->
                      ///
                      if (initialBackground) _initialBackground(),

                      ///
                      /// <--`product list`-->
                      ///
                      state.maybeWhen(
                          orElse: () => Container(),
                          loading: () => Container(
                                padding: const EdgeInsets.only(top: 300),
                                child: const CircularProgressIndicator.adaptive(),
                              ),
                          loaded: (data) => data.isNotEmpty
                              ? Expanded(
                                  child: SmartRefresher(
                                    header: const RefreshClassicHeader(),
                                    controller: _refreshController,
                                    onRefresh: () {
                                      BlocProvider.of<SearchProductListCubit>(context).getSearchProductList(
                                          search: searchController.text, hasDelay: true, hasLoading: true);
                                      _refreshController.refreshCompleted();
                                    },
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.only(top: 22, left: 16, right: 16),
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
                                                // index: selectedSortingIndex,
                                              );
                                            }
                                          },
                                          onTapBranch: () {},
                                        );
                                      },
                                    ),
                                  ),
                                )
                              : _emptyLisBackground())
                    ]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _emptyLisBackground() {
    return Padding(
      padding: const EdgeInsets.only(left: 31, right: 31, top: 177),
      child: Column(
        children: [
          Text(
            context.localized.didnot_find_what_you_needed,
            style: AppTextStyles.fs22w700,
          ),
          const Gap(12),
          Text(
            context.localized.if_you_havenot_found,
            style: AppTextStyles.fs14w400,
            textAlign: TextAlign.center,
          ),
          const Gap(24),
          CustomButton(
            onPressed: context.appBloc.isAuthenticated
                ? () {
                    context.router.push(const SelectCategoriesRoute());
                  }
                : () {
                    context.router.push(const RegisterRoute());
                  },
            style: const ButtonStyle(),
            child: Text(
              context.localized.add_this_to_the_catalog,
              style: AppTextStyles.fs16w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialBackground() {
    return Padding(
      padding: const EdgeInsets.only(left: 28, right: 28, top: 224),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            context.localized.findTheSectionYouNeed,
            style: AppTextStyles.fs22w700.copyWith(height: 1.3),
            textAlign: TextAlign.center,
          ),
          const Gap(12),
          Text(
            '${context.localized.findHerHereAndShareYourImpressions}.', // findHerHereAndShareYourImpressions
            style: AppTextStyles.fs14w400.copyWith(height: 1.3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
        Expanded(
          child: SearchWidget(
            autofocus: true,
            searchController: searchController,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.borderColor,
              ),
            ),
            onChanged: (p0) {
              initialBackground = false;
              BlocProvider.of<SearchProductListCubit>(context).getSearchProductList(search: searchController.text);
              setState(() {});
            },
            // readOnly: true,
          ),
        ),
        const Gap(16)
      ],
    );
  }
}
