import 'dart:developer';
import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/presentation/widgets/dialog/toaster.dart';
import 'package:coment_app/src/core/presentation/widgets/other/custom_loading_overlay_widget.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
import 'package:coment_app/src/feature/auth/presentation/auth.dart';
import 'package:coment_app/src/feature/catalog/bloc/new_product_cubit.dart';
import 'package:coment_app/src/feature/catalog/model/create_product_model.dart';
import 'package:coment_app/src/feature/catalog/presentation/pages/leave_feedback_page.dart';
import 'package:coment_app/src/feature/catalog/presentation/widgets/choose_image_bs.dart';
import 'package:coment_app/src/feature/catalog/widgets/build_star_raiting_widget.dart';
import 'package:coment_app/src/feature/catalog/widgets/city_bs.dart';
import 'package:coment_app/src/feature/catalog/widgets/country_bs.dart';
import 'package:coment_app/src/feature/catalog/widgets/succsesful_added_bs.dart';
import 'package:coment_app/src/feature/main/bloc/city_cubit.dart';
import 'package:coment_app/src/feature/main/bloc/subcatalog_cubit.dart';
import 'package:coment_app/src/feature/main/model/main_dto.dart';
import 'package:coment_app/src/feature/profile/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import 'package:coment_app/src/core/presentation/widgets/textfields/custom_textfield.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/catalog/widgets/sub_category_bs.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

@RoutePage()
class LeaveFeedbackDetailPage extends StatefulWidget
    implements AutoRouteWrapper {
  final String categoryTitle;
  final List<CountryDTO> countryDTO;
  final int categoryId;
  final CreateProductModel value;
  const LeaveFeedbackDetailPage(
      {super.key,
      required this.categoryTitle,
      required this.categoryId,
      required this.value,
      required this.countryDTO});

  @override
  State<LeaveFeedbackDetailPage> createState() =>
      _LeaveFeedbackDetailPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(
        create: (context) => SubcatalogCubit(
          repository: context.repository.mainRepository,
        ),
      ),
      BlocProvider(
        create: (context) => CityCubit(
          repository: context.repository.mainRepository,
        ),
      ),
      BlocProvider(
        create: (context) => NewProductCubit(
          repository: context.repository.catalogRepository,
        ),
      ),
    ], child: this);
  }
}

class _LeaveFeedbackDetailPageState extends State<LeaveFeedbackDetailPage> {
  // name of product
  final TextEditingController nameController = TextEditingController();

  // address
  final TextEditingController addressController = TextEditingController();

  // link
  final TextEditingController linkController = TextEditingController();

  // category
  final TextEditingController categoryController = TextEditingController();

  //  subcatalog list
  final TextEditingController subCategoryController = TextEditingController();
  List<SubCatalogDTO> subCatalogList = [];
  int? subCatalogIndex;
  bool addSubCat = false;

  // phone number
  final TextEditingController phoneController = TextEditingController();

  // country
  final TextEditingController countryController = TextEditingController();
  int? countryIndex;

  // city
  final TextEditingController cityController = TextEditingController();
  int? cityId;
  List<CityDTO> cityList = [];

  // add product images
  List<File> imageFileList = [];

  // add feedback images
  List<File> feedbackImageFileList = [];

  // rating
  int _selectedRating = 0;

  // feedback text
  final TextEditingController feedbackController = TextEditingController();
  final ValueNotifier<String?> _feedbackError = ValueNotifier(null);
  final ValueNotifier<String?> _phoneError = ValueNotifier(null);

  bool allowTapButton = false;
  bool _isOwner = false;
  bool visibleError = false;
  Country? selectedCountry;
  MaskTextInputFormatter? _phoneMaskFormatter;

  // void checkAllowTapButton() {
  //   final isSubCatValid = subCategoryController.text.isNotEmpty;
  //   final isNameValid = nameController.text.isNotEmpty;
  //   final isAddressValid = addressController.text.isNotEmpty;
  //   final isPhoneValid = phoneController.text.length == 16;
  //   final isCountryValid = countryController.text.isNotEmpty;
  //   final isCityValid = cityController.text.isNotEmpty;
  //   final isProductImagesValid = imageFileList.isNotEmpty;

  //   final isFeedbackImagesValid = feedbackImageFileList.isNotEmpty;
  //   final isRatingValid = _selectedRating != 0;
  //   final isFeedbackTextValid = feedbackController.text.isNotEmpty;

  //   allowTapButton = isSubCatValid &&
  //       isNameValid &&
  //       isAddressValid &&
  //       isPhoneValid &&
  //       isCountryValid &&
  //       isProductImagesValid &&
  //       isRatingValid &&
  //       isFeedbackTextValid &&
  //       isFeedbackImagesValid &&
  //       isCityValid;
  //   setState(() {});
  // }
  void checkAllowTapButton() {
    final phoneUnmasked =
        phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final isPhoneValid = phoneUnmasked.length == selectedCountry!.digitLength;

    final isSubCatValid = subCategoryController.text.isNotEmpty;
    final isNameValid = nameController.text.isNotEmpty;
    final isAddressValid = addressController.text.isNotEmpty;
    final isCountryValid = countryController.text.isNotEmpty;
    final isCityValid = cityController.text.isNotEmpty;
    final isProductImagesValid = imageFileList.isNotEmpty;

    final isFeedbackValid = _isOwner
        ? true
        : (_selectedRating != 0 &&
            feedbackController.text.isNotEmpty &&
            feedbackImageFileList.isNotEmpty);

    allowTapButton = isSubCatValid &&
        isNameValid &&
        isAddressValid &&
        isPhoneValid &&
        isCountryValid &&
        isCityValid &&
        isProductImagesValid &&
        isFeedbackValid;

    setState(() {});
  }

  @override
  void initState() {
    BlocProvider.of<SubcatalogCubit>(context)
        .getSubcatalogList(catalogId: widget.categoryId);
    categoryController.text = widget.categoryTitle;
    nameController.text = widget.value.productName ?? '';
    addressController.text = widget.value.address ?? '';
    phoneController.text = widget.value.phoneNumber ?? '';
    linkController.text = widget.value.link ?? '';
    subCategoryController.text = widget.value.subCategoryTitle ?? '';
    // if (phoneController.text != '') {
    //   parsePhoneNumber('${widget.value.phoneNumber}');
    // } else {
    //   selectedCountry = countries.first;
    // }
    final phone = widget.value.phoneNumber;
    if (phone != null && phone.isNotEmpty) {
      if (phone.startsWith('+7')) {
        _updateCountryAndFormat(
          countries.firstWhere((c) => c.code == '+7'),
          initialPhone: phone,
        );
      } else if (phone.startsWith('+998')) {
        _updateCountryAndFormat(
          countries.firstWhere((c) => c.code == '+998'),
          initialPhone: phone,
        );
      } else {
        // fallback
        _updateCountryAndFormat(countries.first, initialPhone: phone);
      }
    } else {
      _updateCountryAndFormat(countries.first);
    }

    imageFileList = widget.value.productImages ?? [];
    _selectedRating = widget.value.rating ?? 0;
    feedbackController.text = widget.value.feedbackText ?? '';
    feedbackImageFileList = widget.value.feedbackImages ?? [];
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    linkController.dispose();
    categoryController.dispose();
    subCategoryController.dispose();
    phoneController.dispose();
    countryController.dispose();
    cityController.dispose();
    feedbackController.dispose();
    _feedbackError.dispose();
    _phoneError.dispose();
    super.dispose();
  }

  void parsePhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith("+7")) {
      selectedCountry = countries.firstWhere((c) => c.code == "+7");

      phoneController.text = phoneNumber
          .substring(2)
          .replaceAll(RegExp(r'[^0-9]'), ''); // Убираем "+7"
    } else if (phoneNumber.startsWith("+998")) {
      selectedCountry = countries.firstWhere((c) => c.code == "+998");
      phoneController.text = phoneNumber
          .substring(4)
          .replaceAll(RegExp(r'[^0-9]'), ''); // Убираем "+998"
    } else {
      selectedCountry = countries.first;
      phoneController.text = phoneNumber.replaceAll(
          RegExp(r'[^0-9]'), ''); // Записываем весь номер
    }
  }

  void _updateCountryAndFormat(Country newCountry, {String? initialPhone}) {
    setState(() {
      selectedCountry = newCountry;
      _phoneMaskFormatter = MaskTextInputFormatter(
        mask: newCountry.mask,
        filter: {"#": RegExp(r'[0-9]')},
      );

      if (initialPhone != null) {
        // Убираем всё, кроме цифр
        final digitsOnly = initialPhone.replaceAll(RegExp(r'[^0-9]'), '');
        // Применяем маску
        phoneController.text = _phoneMaskFormatter!.maskText(digitsOnly);
        // format(digitsOnly);
      } else {
        phoneController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileBLoC>().state;
    final isOwner = profileState.maybeWhen(
      loaded: (userDTO) => userDTO.role == 'owner',
      orElse: () => false,
    );
    _isOwner = isOwner;
    return Consumer<CreateProductModel>(
      builder: (context, value, child) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: LoaderOverlay(
          overlayColor: AppColors.barrierColor,
          overlayWidgetBuilder: (progress) =>
              const CustomLoadingOverlayWidget(),
          child: Scaffold(
            // resizeToAvoidBottomInset: false,
            appBar: CustomAppBar(
              title: widget.categoryTitle,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    left: 16,
                    right: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///
                      /// <--`text fields`-->
                      ///
                      BlocListener<SubcatalogCubit, SubcatalogState>(
                        listener: (context, state) {
                          state.maybeWhen(
                            orElse: () {},
                            loaded: (data) {
                              subCatalogList = data;
                              setState(() {});
                            },
                          );
                        },
                        child: _textFieldSection(value),
                      ),

                      ///
                      /// <--`images`-->
                      ///
                      _addImageSection(value),

                      ///
                      /// <--`add feedback`-->
                      ///
                      if (!isOwner) _addFeedbackSection(value),
                      // _addFeedbackSection(value),
                      const Gap(24),
                      BlocListener<NewProductCubit, NewProductState>(
                        listener: (context, state) {
                          state.maybeWhen(
                            orElse: () {
                              context.loaderOverlay.hide();
                            },
                            loading: () {
                              context.loaderOverlay.show();
                            },
                            loaded: () {
                              context.loaderOverlay.hide();
                              value.categoryId = null;
                              value.categoryTitle = null;
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
                              context.router.popUntil((route) =>
                                  route.settings.name ==
                                  LauncherRoute.name);
                              !_isOwner ? SuccsesfulAddedBs.show(context) : null;
                            },
                          );
                        },
                        child: _buildSubmitButton(value),
                      ),
                      const Gap(16)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _addFeedbackSection(CreateProductModel value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(16),
        Text(
          context.localized.add_a_review,
          style: AppTextStyles.fs16w700.copyWith(height: 1.45),
        ),
        const Gap(8),
        Text(
          context.localized.rate_this_place_to_keep_a_review,
          style: AppTextStyles.fs14w400.copyWith(height: 1.3),
        ),
        const Gap(14),
        BuildStarRaitingWidget(
          selectedRating: _selectedRating,
          onRatingSelected: (rating) {
            setState(() {
              if (rating - 1 == 0 && _selectedRating == 1) {
                _selectedRating = 0;
                value.rating = 0;
              } else {
                _selectedRating = rating;
                value.rating = rating;
              }
              checkAllowTapButton();
            });
          },
        ),
        const Gap(25),
        TextField(
          controller: feedbackController,
          onChanged: (v) {
            feedbackController.text = v;
            value.feedbackText = v;
            checkAllowTapButton();
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: context.localized.write_a_review,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 6),

        // Word Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (visibleError)
                Text(
                  context.localized.minFiveWords,
                  style: AppTextStyles.fs12w600.copyWith(color: AppColors.red2),
                )
              else
                Container(),
              Text(
                  "${countWords(feedbackController.text)}/15 ${context.localized.words}",
                  style: AppTextStyles.fs12w600
                      .copyWith(color: AppColors.base400)),
            ],
          ),
        ),
        const Gap(14),
        SizedBox(
          width: double.infinity,
          child: feedbackImageFileList.isEmpty
              ? CustomButton(
                  height: 52,
                  onPressed: () async {
                    await ChooseImageBottomSheet.show(
                      context,
                      avatar: false,
                      image: (image) {
                        if (image != null) {
                          feedbackImageFileList.add(image);
                          value.feedbackImages = feedbackImageFileList;
                          checkAllowTapButton();
                        }
                        setState(() {});
                      },
                    );
                  },
                  style: CustomButtonStyles.primaryButtonStyle(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.localized.addPhoto, //addPhoto
                        style: AppTextStyles.fs16w500.copyWith(
                          color: AppColors.mainColor,
                        ),
                      ),
                      const Gap(10),
                      const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.mainColor,
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: feedbackImageFileList.length,
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding:
                                  EdgeInsets.only(left: index == 0 ? 0 : 10.0),
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(12)),
                                child: Stack(
                                  children: [
                                    Image.file(
                                      File(feedbackImageFileList[index].path),
                                      height: 80,
                                      width: 90,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            feedbackImageFileList
                                                .removeAt(index);
                                            value.feedbackImages =
                                                feedbackImageFileList;
                                            checkAllowTapButton();
                                          });
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              color: AppColors.backgroundInput,
                                              shape: BoxShape.circle),
                                          child: SvgPicture.asset(
                                            AssetsConstants.close,
                                            height: 20,
                                            width: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const Gap(8),
                      if (feedbackImageFileList.length < 5)
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: InkWell(
                            onTap: () async {
                              await ChooseImageBottomSheet.show(
                                context,
                                avatar: false,
                                image: (image) {
                                  if (image != null) {
                                    feedbackImageFileList.add(image);
                                    value.feedbackImages =
                                        feedbackImageFileList;
                                  }
                                  checkAllowTapButton();

                                  setState(() {});
                                },
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.mainColor, width: 1),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 28, horizontal: 32),
                                child: SvgPicture.asset(
                                  AssetsConstants.addPurple,
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _addImageSection(CreateProductModel value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.localized.image,
          style: AppTextStyles.fs16w700.copyWith(height: 1.45),
        ),
        const Gap(8),
        Text(
          context.localized.upload_a_photo,
          style: AppTextStyles.fs14w400,
        ),
        const Gap(14),
        SizedBox(
          width: double.infinity,
          child: imageFileList.isEmpty
              ? CustomButton(
                  height: 52,
                  onPressed: () async {
                    await ChooseImageBottomSheet.show(
                      context,
                      avatar: false,
                      image: (image) {
                        if (image != null) {
                          imageFileList.add(image);
                          value.productImages = imageFileList;
                        }
                        checkAllowTapButton();
                        setState(() {});
                      },
                    );
                  },
                  style: CustomButtonStyles.primaryButtonStyle(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.localized.addPhoto,
                        style: AppTextStyles.fs16w500.copyWith(
                          color: AppColors.mainColor,
                        ),
                      ),
                      const Gap(10),
                      const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.mainColor,
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: imageFileList.length,
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding:
                                  EdgeInsets.only(left: index == 0 ? 0 : 10.0),
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(12)),
                                child: Stack(
                                  children: [
                                    Image.file(
                                      File(imageFileList[index].path),
                                      height: 80,
                                      width: 90,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            imageFileList.removeAt(index);
                                            value.productImages = imageFileList;
                                            checkAllowTapButton();
                                          });
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              color: AppColors.backgroundInput,
                                              shape: BoxShape.circle),
                                          child: SvgPicture.asset(
                                            AssetsConstants.close,
                                            height: 20,
                                            width: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const Gap(8),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(CreateProductModel value) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        onPressed: () async {
          if (allowTapButton) {
            // 👇 Для владельца — отправляем заглушки, чтобы пройти валидацию бэкенда
            final String commentToSend = _isOwner
                ? '-'
                : (value.feedbackText?.isNotEmpty == true
                    ? value.feedbackText!
                    : '-');
            final int ratingToSend = _isOwner
                ? 1
                : (value.rating != null && value.rating != 0
                    ? value.rating!
                    : 1);

            try {
              await BlocProvider.of<NewProductCubit>(context).createNewProduct(
                cityId: value.cityId ?? 0,
                countryId: value.countryId ?? 0,
                name: value.productName ?? '',
                address: value.address ?? '',
                organisationPhone: value.phoneNumber ?? '',
                websiteUrl: value.link ?? '',
                catalogId: value.categoryId ?? 0,
                subCatalogId: value.subCategoryId ?? 0,
                comment: commentToSend,
                rating: ratingToSend,
                nameSubCatalog: value.subCategoryId == null
                    ? value.subCategoryTitle ?? ''
                    : '',
                image: imageFileList.isNotEmpty ? imageFileList.first : null,
                imageFeedback: _isOwner ? null : feedbackImageFileList,
              );
              if (!mounted) return;
              Toaster.showTopShortToast(context,
                  message: 'Компания успешно добавлена!');
            } catch (e) {
              Toaster.showTopShortToast(context, message: e.toString());
            }

            // BlocProvider.of<NewProductCubit>(context).createNewProduct(
            //     cityId: value.cityId ?? 0,
            //     countryId: value.countryId ?? 0,
            //     name: value.productName ?? '',
            //     address: value.address ?? '',
            //     organisationPhone: value.phoneNumber ?? '',
            //     websiteUrl: value.link ?? '',
            //     catalogId: value.categoryId ?? 0,
            //     subCatalogId: value.subCategoryId ?? 0,
            //     comment: value.feedbackText ?? '',
            //     rating: value.rating ?? 0,
            //     nameSubCatalog:
            //         value.subCategoryId == null ? value.subCategoryTitle : '',
            //     image: imageFileList.first,
            //     imageFeedback: feedbackImageFileList);
            setState(() {});
          }
          log('${value.categoryId} => ${value.categoryTitle}');
          log('${value.subCategoryId} => ${value.subCategoryTitle}');
          log('${value.productName}');
          log('${value.address}');
          log('${value.phoneNumber}');
          log('${value.link}');
          log('${value.countryId} => ${value.countryTitle}');
          log('${value.cityId} => ${value.cityTitle}');
          log('${value.productImages?.length} => product images');
          log('${value.feedbackImages?.length} => feedback images');
          log('${value.rating}');
          log('${value.feedbackText}');
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              allowTapButton ? AppColors.mainColor : AppColors.greyButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          'Добавить',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: allowTapButton ? Colors.white : AppColors.text),
        ),
      ),
    );
  }

  Widget _textFieldSection(CreateProductModel value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// `category`
        Text(
          context.localized.category,
          style: AppTextStyles.fs14w500.copyWith(height: 1.2),
        ),
        const Gap(8),
        SizedBox(
          height: 44,
          child: CustomTextField(
            readOnly: true,
            textStyle: AppTextStyles.fs14w500,
            onTap: () {
              context.router.maybePop();
            },
            onChanged: (text) {
              checkAllowTapButton();
            },
            controller: categoryController,
            hintText: context.localized.enterYourFullName,
            fillColor: AppColors.btnGrey,
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    width: 1, color: AppColors.borderTextField),
                borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    width: 1, color: AppColors.borderTextField),
                borderRadius: BorderRadius.circular(12)),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(top: 13, bottom: 13),
              child: SvgPicture.asset(
                AssetsConstants.shevron,
              ),
            ),
          ),
        ),
        const Gap(16),

        /// `subcategory`
        Text(
          context.localized.subcategory,
          style: AppTextStyles.fs14w500.copyWith(height: 1.2),
        ),
        const Gap(8),
        if (!addSubCat)
          SizedBox(
            height: 44,
            child: CustomTextField(
              readOnly: true,
              textStyle: AppTextStyles.fs14w500,
              onTap: () {
                SubCategoryBs.show(
                  context,
                  subCatalogList: subCatalogList,
                  index: subCatalogIndex,
                  selectedSubCatalog: (id, title, index) {
                    subCategoryController.text = title ?? '';
                    subCatalogIndex = index;
                    value.subCategoryId = id;
                    value.subCategoryTitle = title;
                    setState(() {});
                    checkAllowTapButton();
                  },
                  addNewSubcategory: (isAdd) {
                    addSubCat = isAdd;
                    setState(() {});
                  },
                );
              },
              onChanged: (text) {
                value.subCategoryTitle = text;
                checkAllowTapButton();
              },
              controller: subCategoryController,
              hintText: 'Выберите подкатегорию',
              fillColor: AppColors.btnGrey,
              hintStyle:
                  AppTextStyles.fs14w500.copyWith(color: AppColors.base400),
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      width: 1, color: AppColors.borderTextField),
                  borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      width: 1, color: AppColors.borderTextField),
                  borderRadius: BorderRadius.circular(12)),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(top: 13, bottom: 13),
                child: SvgPicture.asset(
                  AssetsConstants.shevron,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 44,
            child: CustomTextField(
              textStyle: AppTextStyles.fs14w500,
              controller: subCategoryController,
              hintText: 'Название подкатегорий',
              onChanged: (text) {
                value.subCategoryTitle = text;
                checkAllowTapButton();
              },
              fillColor: AppColors.btnGrey,
              hintStyle:
                  AppTextStyles.fs14w500.copyWith(color: AppColors.base400),
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      width: 1, color: AppColors.borderTextField),
                  borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      width: 1, color: AppColors.borderTextField),
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        const Gap(16),

        /// `name of product`
        Text(
          context.localized.name,
          style: AppTextStyles.fs14w500.copyWith(height: 1.2),
        ),
        const Gap(8),
        SizedBox(
          height: 44,
          child: CustomTextField(
            textStyle: AppTextStyles.fs14w500,
            controller: nameController,
            hintText: context.localized.name,
            fillColor: AppColors.btnGrey,
            onChanged: (text) {
              value.productName = text;
              checkAllowTapButton();
            },
            hintStyle:
                AppTextStyles.fs14w500.copyWith(color: AppColors.base400),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    width: 1, color: AppColors.borderTextField),
                borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    width: 1, color: AppColors.borderTextField),
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const Gap(16),

        /// `address`
        Text(
          'Адрес',
          style: AppTextStyles.fs14w500.copyWith(height: 1.2),
        ),
        const Gap(8),
        SizedBox(
          height: 44,
          child: CustomTextField(
            textStyle: AppTextStyles.fs14w500,
            controller: addressController,
            fillColor: AppColors.btnGrey,
            onChanged: (text) {
              value.address = text;
              checkAllowTapButton();
            },
            hintText: '${context.localized.name} адреса',
            hintStyle:
                AppTextStyles.fs14w500.copyWith(color: AppColors.base400),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    width: 1, color: AppColors.borderTextField),
                borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    width: 1, color: AppColors.borderTextField),
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const Gap(16),

        /// `phone number`
        Text(
          'Номер телефона адреса',
          style: AppTextStyles.fs14w500.copyWith(height: 1.2),
        ),
        const Gap(8),

        Row(
          children: [
            Expanded(
              child: CustomTextField(
                key: Key(selectedCountry?.code ?? 'default'),
                height: 44,
                obscureText: false,
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        width: 1, color: AppColors.borderTextField),
                    borderRadius: BorderRadius.circular(12)),
                prefixIconWidget: Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: DropdownButton<Country>(
                    value: selectedCountry,
                    borderRadius: BorderRadius.circular(12),
                    items: countries.map((country) {
                      return DropdownMenuItem<Country>(
                        value: country,
                        child: Text('${country.name} ${country.code}'),
                      );
                    }).toList(),
                    onChanged: (Country? newCountry) {
                      if (newCountry != null) {
                        _updateCountryAndFormat(newCountry);
                        // setState(() {
                        //   selectedCountry = newCountry;
                        //   phoneController.clear();
                        // });
                      }
                    },
                    dropdownColor: Colors.white,
                    underline: const SizedBox(),
                  ),
                ),
                controller: phoneController,
                inputFormatters: [
                  _phoneMaskFormatter ??
                      MaskTextInputFormatter(mask: '##########')
                  // MaskTextInputFormatter(
                  //   mask: selectedCountry?.mask,
                  //   filter: {"#": RegExp(r'[0-9]')},
                  // ),
                ],
                keyboardType: TextInputType.phone,
                hintText: selectedCountry?.mask.replaceAll('#', '_'),
                onChanged: (value) {
                  final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                  widget.value.phoneNumber =
                      '${selectedCountry!.code}$digitsOnly';
                  checkAllowTapButton();
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return _phoneError.value =
                        context.localized.required_to_fill;
                  }
                  String unmasked = value.replaceAll(RegExp(r'[^0-9]'), '');
                  if (unmasked.length != selectedCountry!.digitLength) {
                    // return _phoneError.value =
                    //     context.localized.incorrectNumberFormat;
                  }
                  return _phoneError.value = null;
                },
              ),
            ),
          ],
        ),

        const Gap(16),

        /// `link`
        Text(
          'Ссылка на сайт',
          style: AppTextStyles.fs14w500.copyWith(height: 1.2),
        ),
        const Gap(8),
        SizedBox(
          height: 44,
          child: CustomTextField(
            textStyle: AppTextStyles.fs14w500,
            controller: linkController,
            hintText: 'Ссылка',
            onChanged: (text) {
              value.link = text;
              checkAllowTapButton();
            },
            fillColor: AppColors.btnGrey,
            hintStyle:
                AppTextStyles.fs14w500.copyWith(color: AppColors.base400),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    width: 1, color: AppColors.borderTextField),
                borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    width: 1, color: AppColors.borderTextField),
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const Gap(16),

        /// `country`
        Text(
          'Страна',
          style: AppTextStyles.fs14w500.copyWith(height: 1.2),
        ),
        const Gap(8),
        SizedBox(
          height: 44,
          child: CustomTextField(
            readOnly: true,
            textStyle: AppTextStyles.fs14w500,
            onTap: () {
              CountryBs.show(
                context,
                index: countryIndex,
                countryDTO: widget.countryDTO,
                selectedCountry: (id, title, index) {
                  BlocProvider.of<CityCubit>(context)
                      .getCityList(countryId: id ?? 0);
                  countryIndex = index;
                  countryController.text = title ?? '';
                  value.countryTitle = title;
                  value.countryId = id;
                  checkAllowTapButton();
                  setState(() {});
                },
              );
            },
            onChanged: (text) {
              checkAllowTapButton();
            },
            controller: countryController,
            hintText: 'Название страны',
            fillColor: AppColors.btnGrey,
            hintStyle:
                AppTextStyles.fs14w500.copyWith(color: AppColors.base400),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    width: 1, color: AppColors.borderTextField),
                borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    width: 1, color: AppColors.borderTextField),
                borderRadius: BorderRadius.circular(12)),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(top: 13, bottom: 13),
              child: SvgPicture.asset(
                AssetsConstants.shevron,
              ),
            ),
          ),
        ),
        const Gap(16),

        /// `city`
        BlocListener<CityCubit, CityState>(
            listener: (context, state) {
              state.maybeWhen(
                orElse: () {},
                loading: () {},
                loaded: (data) {
                  if (data.isNotEmpty) {
                    for (int i = 0; i < data.length; i++) {
                      cityList.add(data[i]);
                    }
                  } else {
                    cityList = [];
                  }
                  setState(() {});
                },
              );
            },
            child: cityList.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Город',
                        style: AppTextStyles.fs14w500.copyWith(height: 1.2),
                      ),
                      const Gap(8),
                      SizedBox(
                        height: 44,
                        child: CustomTextField(
                          readOnly: true,
                          textStyle: AppTextStyles.fs14w500,
                          onTap: () {
                            CityBs.show(
                              context,
                              id: cityId,
                              cityDTO: cityList,
                              selectedCity: (id, title) {
                                cityId = id;
                                cityController.text = title ?? '';
                                value.cityTitle = title;
                                value.cityId = id;
                                checkAllowTapButton();
                                setState(() {});
                              },
                            );
                          },
                          onChanged: (text) {
                            checkAllowTapButton();
                          },
                          controller: cityController,
                          hintText: 'Название город',
                          fillColor: AppColors.btnGrey,
                          hintStyle: AppTextStyles.fs14w500
                              .copyWith(color: AppColors.base400),
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 1, color: AppColors.borderTextField),
                              borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 1, color: AppColors.borderTextField),
                              borderRadius: BorderRadius.circular(12)),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(top: 13, bottom: 13),
                            child: SvgPicture.asset(
                              AssetsConstants.shevron,
                            ),
                          ),
                        ),
                      ),
                      const Gap(16)
                    ],
                  )
                : Container()),
      ],
    );
  }
}
