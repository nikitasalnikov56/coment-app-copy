import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/extensions/build_context.dart';
import 'package:coment_app/src/core/presentation/widgets/bottomsheet/custom_drag_handle.dart';
import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/presentation/widgets/dialog/toaster.dart';
import 'package:coment_app/src/core/presentation/widgets/shimmer/shimmer_box.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/main/bloc/dictionary_cubit.dart';
import 'package:coment_app/src/feature/profile/bloc/profile_bloc.dart';
import 'package:coment_app/src/feature/profile/bloc/profile_edit_cubit.dart';
import 'package:coment_app/src/feature/settings/bloc/app_settings_bloc.dart';
import 'package:coment_app/src/feature/settings/widget/settings_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class LanguageBottomSheet extends StatefulWidget {
  const LanguageBottomSheet(
      {super.key, this.selectedLanguage, this.languageId});

  final Function(String flag, int id)? selectedLanguage;
  final int? languageId;

  @override
  State<LanguageBottomSheet> createState() => _LanguageBottomSheetState();

  static Future<void> show(
    BuildContext context, {
    Function(String flag, int id)? selectedLanguage,
    int? languageId,
  }) =>
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ProfileEditCubit(
                repository: context.repository.profileRepository,
              ),
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => DictionaryCubit(
                  repository: context.repository.mainRepository,
                ),
              ),
            ],
            child: LanguageBottomSheet(
              selectedLanguage: selectedLanguage,
              languageId: languageId,
            ),
          ),
        ),
      );
}

class _LanguageBottomSheetState extends State<LanguageBottomSheet> {
  int? selectedId;
  String? selectedFlag;

  bool isLoading = false;

  List<String> languageFlag = [
    AssetsConstants.icKaz,
    AssetsConstants.icRus,
    AssetsConstants.icUz,
    AssetsConstants.icUsa,
    AssetsConstants.icCn,
  ];

  @override
  void initState() {
    BlocProvider.of<DictionaryCubit>(context).getDictionary();
    selectedId = widget.languageId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DictionaryCubit, DictionaryState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          loaded: (mainDTO) {},
        );
      },
      builder: (context, state) {
        return state.maybeWhen(
            orElse: () => LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Align(child: CustomDragHandle()),

                        ///
                        /// title and closing icon
                        ///
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.localized.select_a_language,
                                style: AppTextStyles.fs18w700
                                    .copyWith(height: 1.35),
                              ),
                              IconButton(
                                onPressed: () {
                                  context.router.maybePop();
                                },
                                icon: SvgPicture.asset(
                                  AssetsConstants.close,
                                  height: 26,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(10),

                        ///
                        /// list of address in BasketPage
                        ///
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 4,
                            separatorBuilder: (context, index) => const Gap(12),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              return const ShimmerBox(
                                height: 44,
                                width: double.infinity,
                              );
                            },
                          ),
                        ),

                        ///
                        /// button
                        ///
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 32),
                          child: CustomButton(
                            onPressed: () {},
                            style: CustomButtonStyles.mainButtonStyle(context),
                            child: isLoading
                                ? const CircularProgressIndicator.adaptive()
                                : Text(
                                    context.localized.choose,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const Gap(30),
                      ],
                    );
                  },
                ),
            loaded: (mainDTO) => LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Align(child: CustomDragHandle()),

                        ///
                        /// title and closing icon
                        ///
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.localized.select_a_language,
                                style: AppTextStyles.fs18w700
                                    .copyWith(height: 1.35),
                              ),
                              IconButton(
                                onPressed: () {
                                  context.router.maybePop();
                                },
                                icon: SvgPicture.asset(AssetsConstants.close,
                                    height: 26, placeholderBuilder: (context) {
                                  log('Ошибка: ${AssetsConstants.closeSvgrepo}');
                                  return const Text(
                                      'Ошибка: ${AssetsConstants.closeSvgrepo}');
                                }),
                              ),
                            ],
                          ),
                        ),
                        const Gap(10),

                        ///
                        /// list of address in BasketPage
                        ///
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: languageFlag.length,
                            separatorBuilder: (context, index) => const Gap(12),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              final lang = mainDTO.language?[index];
                              if (lang == null) {
                                return const SizedBox();
                              }
                              final int id = lang.id;

                              final flagByLangId = {
                                1: AssetsConstants.icRus, // ru
                                2: AssetsConstants.icKaz, // kk
                                3: AssetsConstants.icUsa, // en
                                4: AssetsConstants.icUz, // uz
                                5: AssetsConstants.icCn, // zh
                              };
                              final actualFlag =
                                  flagByLangId[id] ?? AssetsConstants.icRus;
                              final String? langName = context
                                          .currentLocale.languageCode ==
                                      'kk'
                                  ? lang.nameKk
                                  : context.currentLocale.languageCode == 'en'
                                      ? lang.nameEn
                                      : context.currentLocale.languageCode ==
                                              'uz'
                                          ? lang.nameUz
                                          : context.currentLocale
                                                      .languageCode ==
                                                  'zh'
                                              ? lang.nameZh ??
                                                  lang.name // ← если nameZh нет — fallback на name
                                              : lang.name;

                              return Container(
                                width: double.infinity,
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
                                        selectedId = id;
                                        selectedFlag = actualFlag;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 16),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                SvgPicture.asset(
                                                  actualFlag,
                                                  width: 20,
                                                  height: 20,
                                                ),
                                                const Gap(10),
                                                Expanded(
                                                  child: Text(
                                                    langName ?? 'Русский',
                                                    style: AppTextStyles
                                                        .fs14w400
                                                        .copyWith(
                                                      color: AppColors.text,
                                                    ),
                                                     overflow: TextOverflow.ellipsis,
                                                     maxLines: 1,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          SvgPicture.asset(
                                            selectedId == id
                                                ? AssetsConstants
                                                    .icRadioBtnActive
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
                        BlocListener<ProfileEditCubit, ProfileEditState>(
                          listener: (context, state) {
                            state.maybeWhen(
                              error: (message) {
                                isLoading = false;
                                Toaster.showErrorTopShortToast(
                                    context, message);
                                //
                              },
                              loading: () {
                                isLoading = true;
                              },
                              loaded: () {
                                isLoading = false;
                                SettingsScope.of(context).add(
                                  AppSettingsEvent.updateAppSettings(
                                    appSettings:
                                        SettingsScope.settingsOf(context)
                                            .copyWith(
                                      locale: selectedId == 2
                                          ? const Locale('kk')
                                          : selectedId == 1
                                              ? const Locale('ru')
                                              : selectedId == 4
                                                  ? const Locale('uz')
                                                  : selectedId == 3
                                                      ? const Locale('en')
                                                      : selectedId == 5
                                                          ? const Locale(
                                                              'zh',
                                                            )
                                                          : const Locale('ru'),
                                    ),
                                  ),
                                );
                                widget.selectedLanguage
                                    ?.call(selectedFlag ?? '', selectedId ?? 0);
                                // log('$selectedFlag');
                                Navigator.of(context).pop();
                                BlocProvider.of<ProfileBLoC>(context)
                                    .add(const ProfileEvent.getProfile());
                                setState(() {});
                              },
                              orElse: () {},
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, top: 32),
                            child: CustomButton(
                              onPressed: () {
                                if (context.appBloc.isAuthenticated) {
                                  BlocProvider.of<ProfileEditCubit>(context)
                                      .editAccount(
                                    password: '',
                                    name: '',
                                    email: '',
                                    avatar: null,
                                    phone: '',
                                    cityId: -1,
                                    languageId: selectedId ?? 0,
                                  );
                                } else {
                                  SettingsScope.of(context).add(
                                    AppSettingsEvent.updateAppSettings(
                                      appSettings:
                                          SettingsScope.settingsOf(context)
                                              .copyWith(
                                        locale: Locale(selectedId == 2
                                            ? 'kk'
                                            : selectedId == 1
                                                ? 'ru'
                                                : selectedId == 4
                                                    ? 'uz'
                                                    : selectedId == 3
                                                        ? 'en'
                                                        : selectedId == 5
                                                            ? 'zh'
                                                            : 'ru'),
                                      ),
                                    ),
                                  );
                                  widget.selectedLanguage?.call(
                                      selectedFlag ?? '', selectedId ?? 0);
                                  // log('$selectedFlag');
                                  Navigator.of(context).pop();
                                }
                                setState(() {});
                              },
                              style:
                                  CustomButtonStyles.mainButtonStyle(context),
                              child: isLoading
                                  ? const CircularProgressIndicator.adaptive()
                                  : Text(
                                      context.localized.choose,
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
                ));
      },
    );
  }
}
