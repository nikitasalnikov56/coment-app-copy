import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/catalog/presentation/widgets/filter_wrap_item.dart';
import 'package:coment_app/src/feature/main/bloc/city_cubit.dart';
import 'package:coment_app/src/feature/main/bloc/dictionary_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class FilterPage extends StatefulWidget implements AutoRouteWrapper {
  const FilterPage({super.key, this.selectedFilter, required this.countryId, required this.cityId});

  final Function(int countryId, int cityId)? selectedFilter;
  final int countryId;
  final int cityId;

  @override
  State<FilterPage> createState() => _FilterPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(
        create: (context) => CityCubit(
          repository: context.repository.mainRepository,
        ),
      ),
      BlocProvider(
        create: (context) => DictionaryCubit(
          repository: context.repository.mainRepository,
        ),
      ),
    ], child: this);
  }
}

class _FilterPageState extends State<FilterPage> {
  int? selectedCountry;
  int? selectedCity;
  bool visibleCity = true;
  @override
  void initState() {
    BlocProvider.of<DictionaryCubit>(context).getDictionary();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isBackButton: false,
        title: context.localized.filter,
        actions: [
          GestureDetector(
            onTap: () {
              context.router.maybePop();
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                context.localized.cancel,
                style: AppTextStyles.fs16w500.copyWith(color: AppColors.mainColor),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<DictionaryCubit, DictionaryState>(
        listener: (context, state) {
          state.maybeWhen(
            orElse: () {},
            loaded: (mainDTO) {
              if (widget.countryId != 0) {
                selectedCountry = widget.countryId;
                log('$selectedCountry dfsfdss');
                if (selectedCountry != null && selectedCountry != 0) {
                  log('$selectedCity');
                  BlocProvider.of<CityCubit>(context).getCityList(countryId: selectedCountry ?? 0);
                  visibleCity = true;
                }
              } else {
                selectedCountry = mainDTO.country?.first.id;
                if (selectedCountry != null && selectedCountry != 0) {
                  log('$selectedCity');
                  BlocProvider.of<CityCubit>(context).getCityList(countryId: selectedCountry ?? 0);
                  visibleCity = true;
                }
              }
              // log(mainDTO.city.toString());
              // (mainDTO.country ?? []).isNotEmpty ? selectedCountry = 1 : selectedCountry = 0;
            },
          );
        },
        builder: (context, state) {
          return state.maybeWhen(
              orElse: () => Container(),
              loaded: (mainDTO) => (mainDTO.country ?? []).isNotEmpty
                  ? SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.localized.country,
                                  style: AppTextStyles.fs14w500.copyWith(height: 1.2),
                                ),
                                const Gap(10),
                                Wrap(
                                  children: List.generate(
                                    (mainDTO.country ?? []).length,
                                    (index) => FilterWrapItem(
                                      title: context.currentLocale.toString() == 'kk'
                                          ? '${mainDTO.country?[index].nameKk}'
                                          : context.currentLocale.toString() == 'en'
                                              ? '${mainDTO.country?[index].nameEn}'
                                              : context.currentLocale.toString() == 'uz'
                                                  ? '${mainDTO.country?[index].nameUz}'
                                                  : '${mainDTO.country?[index].name}',
                                      // title: mainDTO.country?[index].name ?? '',
                                      selected: selectedCountry == mainDTO.country?[index].id,
                                      onTap: () {
                                        if (selectedCountry == mainDTO.country?[index].id) {
                                          selectedCountry = null;
                                          selectedCity = null;
                                          visibleCity = false;
                                        } else {
                                          selectedCountry = mainDTO.country?[index].id;
                                          selectedCity = null;
                                          BlocProvider.of<CityCubit>(context)
                                              .getCityList(countryId: selectedCountry ?? 0);
                                          visibleCity = true;
                                        }
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ),
                                const Gap(12),
                                Text(
                                  context.localized.city,
                                  style: AppTextStyles.fs14w500.copyWith(height: 1.2),
                                ),
                                const Gap(10),
                                if (visibleCity)
                                  BlocConsumer<CityCubit, CityState>(
                                    listener: (context, state) {
                                      state.maybeWhen(
                                        orElse: () {},
                                        loaded: (data) {
                                          if (widget.cityId != 0) {
                                            selectedCity = widget.cityId;
                                          }
                                          if (data.isEmpty) {
                                            selectedCity = null;
                                          }
                                        },
                                      );
                                    },
                                    builder: (context, state) {
                                      return state.maybeWhen(
                                          orElse: () => const Center(
                                                child: CircularProgressIndicator.adaptive(
                                                  backgroundColor: AppColors.mainColor,
                                                ),
                                              ),
                                          loaded: (data) => data.isNotEmpty
                                              ? Wrap(
                                                  children: List.generate(
                                                    data.length,
                                                    (index) => FilterWrapItem(
                                                      // title: data[index].name,
                                                      title: context.currentLocale.toString() == 'kk'
                                                          ? '${data[index].nameKk}'
                                                          : context.currentLocale.toString() == 'en'
                                                              ? '${data[index].nameEn}'
                                                              : context.currentLocale.toString() == 'uz'
                                                                  ? '${data[index].nameUz}'
                                                                  : data[index].name,
                                                      selected: selectedCity == data[index].id,
                                                      onTap: () {
                                                        if (selectedCity == data[index].id) {
                                                          selectedCity = null;
                                                        } else {
                                                          selectedCity = data[index].id;
                                                        }

                                                        setState(() {});
                                                      },
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox());
                                    },
                                  ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 32, bottom: 16),
                              child: CustomButton(
                                onPressed: () {
                                  // log('$selectedCountry -- $selectedCity');
                                  widget.selectedFilter?.call(selectedCountry ?? 0, selectedCity ?? 0);
                                  context.router.maybePop();
                                },
                                style: CustomButtonStyles.mainButtonStyle(context),
                                child: Text(context.localized.done, style: AppTextStyles.fs16w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container());
        },
      ),
    );
  }
}

// List<String> countriesList = ['Казахстан', 'Узбекистан', 'Сша', 'Россия', 'Япония', 'Китай', 'Кыргызстан'];
// List<String> citiesList = [
//   'Астана',
//   'Алматы',
//   'Шымкент',
//   'Актобе',
//   'Актау',
//   'Атырау',
//   'Орал',
//   'Оскемен',
//   'Кызылорда',
//   'Павлодар',
//   'Жезказган'
// ];
