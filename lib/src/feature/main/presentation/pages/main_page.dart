import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/constant/constants.dart';
import 'package:coment_app/src/core/extensions/build_context.dart';
import 'package:coment_app/src/core/presentation/widgets/scroll/pull_to_refresh_widgets.dart';
import 'package:coment_app/src/core/presentation/widgets/shimmer/shimmer_box.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/search_widget.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
import 'package:coment_app/src/feature/catalog/presentation/widgets/catalog_grid_items.dart';
import 'package:coment_app/src/feature/main/bloc/city_cubit.dart';
import 'package:coment_app/src/feature/main/bloc/dictionary_cubit.dart';
import 'package:coment_app/src/feature/main/bloc/popular_feedbacks_cubit.dart';
import 'package:coment_app/src/feature/main/bloc/product_list_cubit.dart';
import 'package:coment_app/src/feature/main/model/main_dto.dart';
import 'package:coment_app/src/feature/main/presentation/widgets/city_Main_bottom_sheet.dart';
import 'package:coment_app/src/feature/main/presentation/widgets/popular_feedback_item.dart';
import 'package:coment_app/src/feature/main/presentation/widgets/popular_product_item.dart';
import 'package:coment_app/src/feature/profile/bloc/profile_bloc.dart';
import 'package:coment_app/src/feature/profile/presentation/widgets/language_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

@RoutePage()
class MainPage extends StatefulWidget implements AutoRouteWrapper {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(
        create: (context) => DictionaryCubit(
          repository: context.repository.mainRepository,
        ),
      ),
      BlocProvider(
        create: (context) => CityCubit(
          repository: context.repository.mainRepository,
        ),
      ),
      BlocProvider(
        create: (context) => ProductListCubit(
          repository: context.repository.mainRepository,
        ),
      ),
      BlocProvider(
        create: (context) => PopularFeedbacksCubit(
          repository: context.repository.mainRepository,
        ),
      ),
    ], child: this);
  }
}

class _MainPageState extends State<MainPage> {
  String? selectedLanguage;
  int? selectedLanguageId;
  MainDTO? data;

  int? cityId;
  int? countryId;

  List<String> languageFlag = [
    AssetsConstants.icKaz,
    AssetsConstants.icRus,
    AssetsConstants.icUz,
    AssetsConstants.icUsa,
  ];

  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    BlocProvider.of<DictionaryCubit>(context).getDictionary();
    BlocProvider.of<ProductListCubit>(context).getPopularProductList();
    BlocProvider.of<PopularFeedbacksCubit>(context).getPopularFeedbacks();
    if (context.appBloc.isAuthenticated) {
      BlocProvider.of<ProfileBLoC>(context)
          .add(const ProfileEvent.getProfile());
    } else {
      selectedLanguage = languageFlag[1];
    }
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        header: const RefreshClassicHeader(),
        controller: _refreshController,
        onRefresh: () {
          log('${context.repository.authRepository.user?.city?.name}');
          BlocProvider.of<DictionaryCubit>(context).getDictionary();
          BlocProvider.of<ProductListCubit>(context).getPopularProductList(
              cityId: context.repository.authRepository.cityId);
          BlocProvider.of<PopularFeedbacksCubit>(context).getPopularFeedbacks(
              cityId: context.repository.authRepository.cityId);
          if (context.appBloc.isAuthenticated) {
            BlocProvider.of<ProfileBLoC>(context)
                .add(const ProfileEvent.getProfile());
          }
          _refreshController.refreshCompleted();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///
              /// <-- `Language / search / city` -->
              ///
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BlocConsumer<ProfileBLoC, ProfileState>(
                  listener: (context, state) {
                    state.maybeWhen(
                      error: (message) {},
                      loading: () {},
                      loaded: (userDTO, _) {
                        cityId = userDTO.city?.id;
                        countryId = userDTO.city?.country?.id;

                        selectedLanguage = userDTO.language?.id == 1
                            ? languageFlag[1]
                            : userDTO.language?.id == 2
                                ? languageFlag[0]
                                : userDTO.language?.id == 3
                                    ? languageFlag[3]
                                    : userDTO.language?.id == 4
                                        ? languageFlag[2]
                                        : AssetsConstants.frame;
                        setState(() {});
                      },
                      orElse: () {},
                    );
                  },
                  builder: (context, state) {
                    return Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                              color: AppColors.backgroundColor,
                              border: Border.all(color: AppColors.borderColor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(16))),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                LanguageBottomSheet.show(
                                  context,
                                  languageId: selectedLanguageId,
                                  selectedLanguage: (flag, id) {
                                    selectedLanguage = flag;
                                    selectedLanguageId = id;
                                    setState(() {});
                                  },
                                );
                              },
                              child: Padding(
                                padding:
                                    selectedLanguage == AssetsConstants.frame
                                        ? const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 12)
                                        : const EdgeInsets.symmetric(
                                            vertical: 14, horizontal: 11),
                                child: SvgPicture.asset(
                                  selectedLanguage ?? 'assets/icons/Frame.svg',
                                  width: 19,
                                  height: 19,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Gap(4),
                        Expanded(
                            child: SearchWidget(
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: AppColors.borderColor,
                                    )),
                                readOnly: true,
                                onTap: () => context.router
                                    .push(const AddFeedbackSearchingRoute()))),
                        const Gap(4),
                        DecoratedBox(
                          decoration: BoxDecoration(
                              color: AppColors.backgroundColor,
                              border: Border.all(color: AppColors.borderColor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(16))),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                CityMainBottomSheet.show(
                                  context,
                                  list: data,
                                  cityId: context.appBloc.isAuthenticated
                                      ? cityId
                                      : context
                                          .repository.authRepository.cityId,
                                  countryId: countryId,
                                  isGuest: (p0) {
                                    BlocProvider.of<ProductListCubit>(context)
                                        .getPopularProductList(
                                            cityId: context.repository
                                                .authRepository.cityId);
                                    BlocProvider.of<PopularFeedbacksCubit>(
                                            context)
                                        .getPopularFeedbacks(
                                            cityId: context.repository
                                                .authRepository.cityId);
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: SvgPicture.asset(
                                  AssetsConstants.frame2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Gap(18),

              ///
              /// <-- `Catalog` -->
              ///
              BlocConsumer<DictionaryCubit, DictionaryState>(
                listener: (context, state) {
                  state.maybeWhen(
                    orElse: () {},
                    loaded: (mainDTO) {
                      data = mainDTO;
                      setState(() {});
                    },
                  );
                },
                builder: (context, state) {
                  return state.maybeWhen(
                      orElse: () => _catalogSkeleton(),
                      loaded: (mainDTO) => SizedBox(
                            height: 208,
                            child: GridView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(left: 16, top: 2),
                              scrollDirection: Axis.horizontal,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: mainDTO.catalog?.length,
                              // itemCount: catalogTitle.length,
                              itemBuilder: (context, index) {
                                return CatalogGridItem(
                                  title: context.currentLocale.toString() ==
                                          'kk'
                                      ? '${mainDTO.catalog?[index].nameKk}'
                                      : context.currentLocale.toString() == 'en'
                                          ? '${mainDTO.catalog?[index].nameEn}'
                                          : context.currentLocale.toString() ==
                                                  'uz'
                                              ? '${mainDTO.catalog?[index].nameUz}'
                                              : context.currentLocale
                                                          .toString() ==
                                                      'zh'
                                                  ? '${mainDTO.catalog?[index].nameZh}'
                                                  : '${mainDTO.catalog?[index].name}',
                                  image: mainDTO.catalog?[index].image ??
                                      NOT_FOUND_IMAGE,
                                  index: index,
                                  onTap: () {
                                    context.router.push(SubcatalogRoute(
                                        title: context.currentLocale
                                                    .toString() ==
                                                'kk'
                                            ? '${mainDTO.catalog?[index].nameKk}'
                                            : context.currentLocale
                                                        .toString() ==
                                                    'en'
                                                ? '${mainDTO.catalog?[index].nameEn}'
                                                : context.currentLocale
                                                            .toString() ==
                                                        'uz'
                                                    ? '${mainDTO.catalog?[index].nameUz}'
                                                    : context.currentLocale
                                                                .toString() ==
                                                            'zh'
                                                        ? '${mainDTO.catalog?[index].nameZh}'
                                                        : '${mainDTO.catalog?[index].name}',
                                        catalogId:
                                            mainDTO.catalog?[index].id ?? 0));
                                  },
                                );
                              },
                            ),
                          ));
                },
              ),

              ///
              /// <-- `Discussing products` -->
              ///

              BlocConsumer<ProductListCubit, ProductListState>(
                listener: (context, state) {},
                builder: (context, state) {
                  return state.maybeWhen(
                      orElse: () => _productSkeleton(),
                      loaded: (data) => data.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 18, bottom: 12, left: 16, right: 16),
                                  child: Text(
                                    context
                                        .localized.they_are_discussing_it_now,
                                    style: AppTextStyles.fs16w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 240,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.only(
                                        top: 3, left: 19, right: 3),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: data.length,
                                    itemBuilder: (context, index) {
                                      return PopularProductItem(
                                          data: data[index]);
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Container());
                },
              ),

              ///
              /// <-- `Popular feedbacks` -->
              ///

              BlocConsumer<PopularFeedbacksCubit, PopularFeedbacksState>(
                listener: (context, state) {},
                builder: (context, state) {
                  return state.maybeWhen(
                      orElse: () => _feedbackSkeleton(),
                      loaded: (data) => data.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 12, left: 16),
                                  child: Text(
                                    context.localized.popular_reviews,
                                    style: AppTextStyles.fs16w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 130,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.only(
                                        top: 3, left: 19, right: 3),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: data.length,
                                    itemBuilder: (context, index) {
                                      return PopularFeedbackItem(
                                        data: data[index],
                                        onTap: () {
                                          context.router.push(
                                              FeedbackDetailRoute(
                                                  needPageCard: true,
                                                  id: data[index].id ?? 0,
                                                  userId:
                                                      data[index].user?.id ??
                                                          0));
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Container());
                },
              ),

              const Gap(30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feedbackSkeleton() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 12, left: 16),
            child: Text(
              context.localized.popular_reviews,
              style: AppTextStyles.fs16w600,
            ),
          ),
          SizedBox(
            height: 130,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 3, left: 19, right: 3),
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: ShimmerBox(
                    width: 330,
                    height: 127,
                  ),
                );
              },
            ),
          ),
        ],
      );

  Widget _productSkeleton() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 18, bottom: 12, left: 16, right: 16),
            child: Text(
              context.localized.they_are_discussing_it_now,
              style: AppTextStyles.fs16w600,
            ),
          ),
          SizedBox(
            height: 240,
            child: ListView.separated(
              shrinkWrap: true,
              separatorBuilder: (context, index) => const Gap(10),
              padding: const EdgeInsets.only(top: 3, left: 19, right: 3),
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) {
                return const Column(
                  children: [
                    ShimmerBox(
                      height: 160,
                      width: 160,
                    ),
                    Gap(6),
                    ShimmerBox(
                      height: 32,
                      width: 160,
                    ),
                    Gap(6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerBox(
                          height: 20,
                          width: 80,
                        ),
                        Gap(50),
                        ShimmerBox(
                          height: 20,
                          width: 30,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      );

  Widget _catalogSkeleton() => SizedBox(
        height: 208,
        child: GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.only(left: 16, top: 2),
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 10,
          // itemCount: catalogTitle.length,
          itemBuilder: (context, index) {
            return const Column(
              children: [
                ShimmerBox(
                  radius: 50,
                  width: 72,
                  height: 72,
                ),
                Gap(6),
                ShimmerBox(
                  height: 18,
                )
              ],
            );
          },
        ),
      );
}
