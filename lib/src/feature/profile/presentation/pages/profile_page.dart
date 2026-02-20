import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/constant/constants.dart';
import 'package:coment_app/src/core/presentation/widgets/dialog/toaster.dart';
import 'package:coment_app/src/core/presentation/widgets/scroll/pull_to_refresh_widgets.dart';
import 'package:coment_app/src/core/presentation/widgets/shimmer/shimmer_box.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/bloc/app_bloc.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
import 'package:coment_app/src/feature/main/bloc/dictionary_cubit.dart';
import 'package:coment_app/src/feature/main/presentation/widgets/city_main_bottom_sheet.dart';
import 'package:coment_app/src/feature/profile/bloc/profile_bloc.dart';
import 'package:coment_app/src/feature/profile/models/response/verification_status.dart';
import 'package:coment_app/src/feature/profile/presentation/widgets/language_bottom_sheet.dart';
import 'package:coment_app/src/feature/profile/presentation/widgets/logout_bottom_sheet.dart';
import 'package:coment_app/src/feature/profile/presentation/widgets/profile_avatar.dart';
import 'package:coment_app/src/feature/profile/presentation/widgets/profile_row_button.dart';
import 'package:coment_app/src/feature/profile/presentation/widgets/support_service_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<ProfileBLoC>(context).add(const ProfileEvent.getProfile());
    BlocProvider.of<ProfileBLoC>(context)
        .add(const ProfileEvent.getVerificationStatus());
    BlocProvider.of<DictionaryCubit>(context).getDictionary();
  }

  final RefreshController _refreshController = RefreshController();

  int? selectedLanguageId;

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // log('${context.appBloc.isAuthenticated}', name: 'profile page');
    return LoaderOverlay(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.white,
        appBar: CustomAppBar(
          title: context.localized.profile,
          isBackButton: false,
          shape: const Border(
            bottom: BorderSide(
              color: AppColors.dividerColor,
              width: 0.5,
            ),
          ),
        ),
        body: BlocConsumer<ProfileBLoC, ProfileState>(
          listener: (context, state) {
            state.maybeWhen(
              error: (message) {
                context.loaderOverlay.hide();
                Toaster.showErrorTopShortToast(context, message);
              },
              loading: () {
                // context.loaderOverlay.show();
                _refreshController.resetNoData();
              },
              exited: (message) {
                context.loaderOverlay.hide();
                Toaster.showTopShortToast(context, message: 'Успешно');
                // context.router.popUntil((route) => route.settings.name == LauncherRoute.name);
                BlocProvider.of<AppBloc>(context).add(const AppEvent.exiting());
              },
              loaded: (userDTO, _) {
                selectedLanguageId = userDTO.language?.id;
                setState(() {});
              },
              orElse: () {
                context.loaderOverlay.hide();
              },
            );
          },
          builder: (context, state) {
            return state.maybeWhen(
              loading: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              orElse: () {
                return const Center(
                  child: Text("Ошибка загрузки"),
                );
              },
              loaded: (userDTO, verificationStatus) {


                final userRole = userDTO.role?.toLowerCase().trim() ?? '';
                final isOwner = userRole == 'owner';
                return SmartRefresher(
                  header: const RefreshClassicHeader(),
                  controller: _refreshController,
                  onRefresh: () async {
                    final bloc = BlocProvider.of<ProfileBLoC>(context);

                    bloc.add(const ProfileEvent.getProfile());
                    bloc.add(const ProfileEvent.getVerificationStatus());
                    BlocProvider.of<DictionaryCubit>(context).getDictionary();
                    _refreshController.refreshCompleted();
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList.list(
                          children: [
                            const Gap(8),

                            ///
                            /// <-- `profile avatar, name, email` -->
                            ///
                            ///
                            Container(
                              decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(16)),
                              alignment: Alignment.center,
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      context.router.push(DetailAvatarRoute(
                                          image: userDTO.avatar ??
                                              NOT_FOUND_IMAGE));
                                    },
                                    child: ProfileAvatarWithRating(
                                      imageAva:
                                          userDTO.avatar ?? NOT_FOUND_IMAGE,
                                      rating: userDTO.rating ?? 1,
                                    ),
                                  ),
                                  const Gap(12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userDTO.name ?? '',
                                        style: AppTextStyles.fs18w500.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.text,
                                          height: 1.2,
                                        ),
                                      ),
                                      if (verificationStatus != null)
                                        _buildVerificationStatus(
                                            verificationStatus),
                                      const Gap(8),
                                      Text(
                                        userDTO.email ?? '',
                                        style: AppTextStyles.fs14w400.copyWith(
                                          color: AppColors.text,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Gap(16),

                            ///
                            /// <-- `edit profile` -->
                            ///
                            ProfileRowButton(
                              icon: AssetsConstants.icEditProfile,
                              title: context.localized.editProfile,
                              onTap: () {
                                context.router.push(
                                  EditProfileRoute(
                                    user: userDTO,
                                  ),
                                );
                              },
                            ),
                            const Gap(12),

                            ///
                            /// rating
                            ///
                            ProfileRowButton(
                              icon: AssetsConstants.icRaiting,
                              title: context.localized.rating,
                              onTap: () {
                                context.router.push(const RaitingRoute());
                              },
                            ),
                            const Gap(12),

                            ///
                            /// history of my reviews
                            ///
                            ProfileRowButton(
                              icon: AssetsConstants.icReviewHistory,
                              title: context.localized.historyOfMyReview,
                              onTap: () {
                                context.router.push(
                                  const ReviewHistoryRoute(),
                                );
                              },
                            ),
                            const Gap(12),

                            ///
                            /// helpdesk
                            ///
                            ProfileRowButton(
                              icon: AssetsConstants.icHelpdesk,
                              title: context.localized.helpDesk,
                              onTap: () {
                                SupportServiceBottomSheet.show(context,
                                    user: userDTO);
                              },
                            ),
                            const Gap(12),

                            ///
                            /// language
                            ///
                            ProfileRowButton(
                              icon: AssetsConstants.icLanguage,
                              title: context.localized.language,
                              onTap: () {
                                LanguageBottomSheet.show(
                                  context,
                                  languageId: userDTO.language?.id,
                                  selectedLanguage: (flag, id) {
                                    selectedLanguageId = id;
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                            const Gap(12),

                            ///
                            /// <-- `City` -->
                            ///
                            BlocBuilder<DictionaryCubit, DictionaryState>(
                              builder: (context, state) {
                                return state.maybeWhen(
                                    orElse: () => const ShimmerBox(
                                          height: 34,
                                          width: double.infinity,
                                        ),
                                    loaded: (mainDTO) => ProfileRowButton(
                                          icon: AssetsConstants.icCity,
                                          title: (userDTO.city?.country?.name !=
                                                      null &&
                                                  userDTO.city?.name != null)
                                              ? context.currentLocale
                                                          .toString() ==
                                                      'kk'
                                                  ? '${userDTO.city?.country?.nameKk}'
                                                  : context.currentLocale
                                                              .toString() ==
                                                          'en'
                                                      ? '${userDTO.city?.country?.nameEn}'
                                                      : context.currentLocale
                                                                  .toString() ==
                                                              'uz'
                                                          ? '${userDTO.city?.country?.nameUz}'
                                                          : '${userDTO.city?.country?.name}'
                                              : context
                                                  .localized.countryAndCity,
                                          titleSecond: (userDTO.city?.country
                                                          ?.name !=
                                                      null &&
                                                  userDTO.city?.name != null)
                                              ? context.currentLocale
                                                          .toString() ==
                                                      'kk'
                                                  ? '${userDTO.city?.nameKk}'
                                                  : context.currentLocale
                                                              .toString() ==
                                                          'en'
                                                      ? '${userDTO.city?.nameEn}'
                                                      : context.currentLocale
                                                                  .toString() ==
                                                              'uz'
                                                          ? '${userDTO.city?.nameUz}'
                                                          : '${userDTO.city?.name}'
                                              // ? '${userDTO.city?.name}'
                                              : '',
                                          onTap: () {
                                            CityMainBottomSheet.show(
                                              context,
                                              list: mainDTO,
                                              cityId: userDTO.city?.id,
                                              countryId:
                                                  userDTO.city?.country?.id,
                                              isGuest: (p0) {},
                                            );
                                          },
                                        ));
                              },
                            ),
                            const Gap(12),
                            if (isOwner)
                              Column(
                                spacing: 12,
                                children: [
                                  ProfileRowButton(
                                    icon: AssetsConstants.documentsAdd,
                                    title: context.localized.loadDocuments,
                                    onTap: () {
                                      context.router.push(
                                        const LoadDocumentsRoute(),
                                      );
                                    },
                                  ),
                                  ProfileRowButton(
                                    icon: AssetsConstants.companyAdd,
                                    title: context.localized.companyAdd,
                                    onTap: () {
                                      context.router
                                          .push(const SelectCategoriesRoute());
                                    },
                                  ),
                                  ProfileRowButton(
                                    icon: AssetsConstants.payment,
                                    title: context.localized.payment,
                                    onTap: () {
                                      context.router.push(const PaymentRoute());
                                    },
                                  )
                                ],
                              ),
                            if (isOwner) const Gap(12),
                            // ProfileRowButton(
                            //   icon: AssetsConstants.message,
                            //   title: context.localized.message,
                            //   onTap: () {
                            //     context.router.push(const MessageRoute());
                            //   },
                            // ),
                            // : const SizedBox(),
                            const Gap(12),

                            ///
                            /// <-- `Logout` -->
                            ///
                            ProfileRowButton(
                              icon: AssetsConstants.icLogOut,
                              title: context.localized.logoutOfAccount,
                              onTap: () {
                                LogoutBottomSheet.show(
                                  context,
                                  isDeleteAccount: false,
                                  onPressed: () {
                                    BlocProvider.of<ProfileBLoC>(context)
                                        .add(const ProfileEvent.logOut());
                                    context.router.maybePop();
                                  },
                                );
                              },
                            ),
                            const Gap(20),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildVerificationStatus(VerificationStatus status) {
    String message;
    Color color;
    IconData icon;

    switch (status.status) {
      case 'approved':
        message = 'Верифицирован';
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'pending':
        message = 'На рассмотрении';
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case 'rejected':
        message = ' Отклонено';
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        message = 'Не запрашивалось';
        color = Colors.grey;
        icon = Icons.info_outline;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const Gap(4),
        Text(
          message,
          style: AppTextStyles.fs14w500.copyWith(color: color),
        ),
      ],
    );
  }
}
