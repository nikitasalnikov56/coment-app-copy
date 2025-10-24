import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/extensions/build_context.dart';
import 'package:coment_app/src/core/presentation/widgets/bottomsheet/custom_drag_handle.dart';
import 'package:coment_app/src/core/presentation/widgets/dialog/toaster.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/main/bloc/city_cubit.dart';
import 'package:coment_app/src/feature/main/model/main_dto.dart';
import 'package:coment_app/src/feature/profile/bloc/profile_bloc.dart';
import 'package:coment_app/src/feature/profile/bloc/profile_edit_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:gap/gap.dart';

class CityMainBottomSheet extends StatefulWidget {
  const CityMainBottomSheet({super.key, this.list, this.countryId, this.cityId, this.isGuest});
  final int? countryId;
  final int? cityId;
  final MainDTO? list;
  final Function(bool)? isGuest;

  @override
  State<CityMainBottomSheet> createState() => _CityMainBottomSheetState();

  static Future<void> show(BuildContext context,
          {MainDTO? list, int? cityId, int? countryId, Function(bool)? isGuest}) =>
      showModalBottomSheet(
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
              create: (context) => CityCubit(
                repository: context.repository.mainRepository,
              ),
            ),
            BlocProvider(
              create: (context) => ProfileEditCubit(
                repository: context.repository.profileRepository,
              ),
            ),
          ],
          child: CityMainBottomSheet(
            list: list,
            cityId: cityId,
            countryId: countryId,
            isGuest: isGuest,
          ),
        ),
      );
}

class _CityMainBottomSheetState extends State<CityMainBottomSheet> {
  bool isCountryBs = true;
  bool isLoading = false;
  int? scountryId;
  int? scityId;

  List<CityDTO> cityList = [];

  @override
  void initState() {
    scountryId = widget.countryId;
    scityId = widget.cityId;
    // log('$scityId', name: 'city');
    // log('$scountryId', name: 'country');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CityCubit, CityState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {
            isLoading = false;
          },
          loading: () {
            isLoading = true;
          },
          loaded: (data) {
            isLoading = false;
            isCountryBs = false;
            for (int i = 0; i < data.length; i++) {
              cityList.add(data[i]);
            }
            setState(() {});
          },
        );
      },
      builder: (context, state) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.6,
          initialChildSize: isCountryBs ? 0.4 : 0.6,
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
                    Row(
                      children: [
                        if (!isCountryBs)
                          IconButton(
                            onPressed: () {
                              isCountryBs = true;
                              setState(() {});
                            },
                            icon: SvgPicture.asset(
                              AssetsConstants.icBack,
                            ),
                          ),
                        Padding(
                          padding: isCountryBs ? const EdgeInsets.only(left: 16) : EdgeInsets.zero,
                          child: Text(
                            isCountryBs ? context.localized.select_a_country : context.localized.choose_a_city,
                            style: AppTextStyles.fs18w700.copyWith(height: 1.35),
                          ),
                        ),
                      ],
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
                /// list of address in BasketPage
                ///
                (!isCountryBs && cityList.isEmpty)
                    ? const Expanded(child: Center(child: Text('Empty')))
                    : Expanded(
                        // padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: isCountryBs ? (widget.list?.country ?? []).length : cityList.length,
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
                                    if (isCountryBs) {
                                      scountryId = widget.list?.country?[index].id;
                                    } else {
                                      scityId = cityList[index].id;
                                    }
                                    setState(() {});

                                    // setState(() {
                                    //   selectedIndex = index;
                                    //   if (isCountryBs) {
                                    //     selectedCountryId = widget.list?.country?[index].id;
                                    //   } else {
                                    //     selectedCityId = cityList[index].id;
                                    //   } // selectedFlag = languageFlag[index];
                                    // });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          isCountryBs
                                              ? (context.currentLocale.toString() == 'kk'
                                                  ? '${widget.list?.country?[index].nameKk}'
                                                  : context.currentLocale.toString() == 'en'
                                                      ? '${widget.list?.country?[index].nameEn}'
                                                      : context.currentLocale.toString() == 'uz'
                                                          ? '${widget.list?.country?[index].nameUz}'
                                                          : '${widget.list?.country?[index].name}')
                                              : (context.currentLocale.toString() == 'kk'
                                                  ? '${cityList[index].nameKk}'
                                                  : context.currentLocale.toString() == 'en'
                                                      ? '${cityList[index].nameEn}'
                                                      : context.currentLocale.toString() == 'uz'
                                                          ? '${cityList[index].nameUz}'
                                                          : cityList[index].name),
                                          style: AppTextStyles.fs14w400.copyWith(color: AppColors.text),
                                        ),
                                        SvgPicture.asset(isCountryBs
                                            ? (scountryId == widget.list?.country?[index].id)
                                                ? AssetsConstants.icRadioBtnActive
                                                : AssetsConstants.icRadioBtn
                                            : (scityId == cityList[index].id)
                                                ? AssetsConstants.icRadioBtnActive
                                                : AssetsConstants.icRadioBtn),
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
                BlocListener<ProfileEditCubit, ProfileEditState>(
                  listener: (context, state) {
                    state.maybeWhen(
                      error: (message) {
                        isLoading = false;
                        Toaster.showErrorTopShortToast(context, message);
                      },
                      loading: () {
                        isLoading = true;
                      },
                      loaded: () {
                        isLoading = false;
                        BlocProvider.of<ProfileBLoC>(context).add(const ProfileEvent.getProfile());
                        context.repository.authRepository.setCityId(cityId: scityId ?? 0);
                        widget.isGuest?.call(true);
                        context.router.maybePop();
                      },
                      orElse: () {
                        isLoading = false;
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
                    child: CustomButton(
                      onPressed: () {
                        if (isCountryBs) {
                          cityList = [];
                          BlocProvider.of<CityCubit>(context).getCityList(countryId: scountryId ?? 0);
                        } else {
                          if (context.appBloc.isAuthenticated) {
                            BlocProvider.of<ProfileEditCubit>(context).editAccount(
                                password: '', name: '', email: '', cityId: scityId ?? 0, languageId: -1, phone: '');
                          } else {
                            context.repository.authRepository.setCityId(cityId: scityId ?? 0);
                            widget.isGuest?.call(true);
                            context.router.maybePop();
                          }
                        }
                      },
                      style: CustomButtonStyles.mainButtonStyle(context),
                      child: isLoading
                          ? const CircularProgressIndicator.adaptive(backgroundColor: AppColors.white)
                          : Text(
                              isCountryBs ? context.localized.next : context.localized.choose,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),

                const Gap(30),
              ],
            );
          },
        );
      },
    );
  }
}
