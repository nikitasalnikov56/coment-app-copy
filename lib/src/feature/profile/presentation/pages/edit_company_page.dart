import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coment_app/src/core/presentation/widgets/textfields/custom_textfield.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/auth/presentation/pages/register_page.dart';
import 'package:coment_app/src/feature/catalog/bloc/edit_company_cubit.dart';
import 'package:coment_app/src/feature/main/bloc/city_cubit.dart';
import 'package:coment_app/src/feature/main/bloc/subcatalog_cubit.dart';
import 'package:coment_app/src/feature/main/model/product_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

@RoutePage()
class EditCompanyPage extends StatefulWidget implements AutoRouteWrapper {
  final ProductDTO company;

  const EditCompanyPage({
    super.key,
    required this.company,
  });

  @override
  State<EditCompanyPage> createState() => _EditCompanyPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                SubcatalogCubit(repository: context.repository.mainRepository)),
        BlocProvider(
            create: (context) =>
                CityCubit(repository: context.repository.mainRepository)),
        BlocProvider(
            create: (context) => EditCompanyCubit(
                repository: context.repository.catalogRepository)),
      ],
      child: this,
    );
  }
}

class _EditCompanyPageState extends State<EditCompanyPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController subCategoryController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  int? categoryId;
  int? subCategoryId;
  int? cityId;
  int? countryId;

  File? avatarFile;
  bool allowTapButton = false;

  Country? selectedCountry;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    nameController.text = widget.company.name ?? '';
    addressController.text = widget.company.address ?? '';
    linkController.text = widget.company.displayWebsite;
    categoryController.text = widget.company.catalog?.name ?? '';
    subCategoryController.text = widget.company.subCatalog?.name ?? '';
    countryController.text = widget.company.city?.country?.name ?? '';
    cityController.text = widget.company.city?.name ?? '';

    // Берем уже замаскированный текст напрямую из состояния форматтера
    final phone = widget.company.displayPhone; 
    if (phone != null && phone.isNotEmpty) {
      parsePhoneNumber(phone);
    } else {
      selectedCountry = countries.first;
      phoneController.text = '';
    }

    categoryId = widget.company.catalog?.id;
    subCategoryId = widget.company.subCatalog?.id;
    cityId = widget.company.city?.id;
    countryId = widget.company.city?.country?.id;

    checkAllowTapButton();
  }


  void parsePhoneNumber(String phoneNumber) {
    // Убираем всё кроме цифр и плюса для анализа
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleanPhone.startsWith("+998")) {
      selectedCountry = countries.firstWhere((c) => c.code == "+998");
      // Отсекаем первые 4 символа (+998)
      phoneController.text = cleanPhone.substring(4);
    } else if (cleanPhone.startsWith("+7")) {
      selectedCountry = countries.firstWhere((c) => c.code == "+7");
      // Отсекаем первые 2 символа (+7)
      phoneController.text = cleanPhone.substring(2);
    } else if (cleanPhone.startsWith("998")) {
      // Если пришло без плюса
      selectedCountry = countries.firstWhere((c) => c.code == "+998");
      phoneController.text = cleanPhone.substring(3);
    } else if (cleanPhone.startsWith("7")) {
      // Если пришло без плюса
      selectedCountry = countries.firstWhere((c) => c.code == "+7");
      phoneController.text = cleanPhone.substring(1);
    } else {
      // Дефолт, если код не распознан
      selectedCountry = countries.first;
      phoneController.text = cleanPhone;
    }
  }

  void checkAllowTapButton() {
    String phoneUnmasked =
        phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    bool isPhoneValid = phoneUnmasked.length == selectedCountry?.digitLength;
    setState(() {
      allowTapButton = nameController.text.isNotEmpty &&
          addressController.text.isNotEmpty &&
          isPhoneValid;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    linkController.dispose();
    phoneController.dispose();
    categoryController.dispose();
    subCategoryController.dispose();
    countryController.dispose();
    cityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Вызываем стандартный BottomSheet для выбора источника (как в LeaveFeedbackDetailPage)
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Галерея'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Камера'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80, // Оптимизация размера
      );

      if (pickedFile != null) {
        setState(() {
          avatarFile = File(pickedFile.path);
        });
        checkAllowTapButton();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditCompanyCubit, EditCompanyState>(
      listener: (context, state) {
        state.maybeWhen(
          success: () => context.router.maybePop(true),
          error: (message) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Ошибка: $message'), backgroundColor: Colors.red),
          ),
          orElse: () {},
        );
      },
      builder: (context, state) {
        final isLoading =
            state.maybeWhen(loading: () => true, orElse: () => false);
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            appBar: const CustomAppBar(title: 'Редактирование компании'),
            body: Stack(
              children: [
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Column(
                      children: [
                        _buildAvatarSection(),
                        const Gap(24),
                        _buildLabel('Название компании'),
                        _buildInputField(
                          controller: nameController,
                          hint: 'Название компании',
                          onChanged: (_) => setState(() {}),
                        ),
                        const Gap(16),
                        _buildLabel('Номер телефона'),
                    
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                key: Key(selectedCountry?.code ?? 'default'),
                                height: 44,
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      width: 1,
                                      color: AppColors.borderTextField),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIconWidget: Padding(
                                  padding: const EdgeInsets.only(left: 18.0),
                                  child: DropdownButton<Country>(
                                    value: selectedCountry,
                                    borderRadius: BorderRadius.circular(12),
                                    items: countries.map((country) {
                                      return DropdownMenuItem<Country>(
                                        value: country,
                                        child: Text(
                                            '${country.name} ${country.code}'),
                                      );
                                    }).toList(),
                                    onChanged: (Country? newCountry) {
                                      if (newCountry != null) {
                                        setState(() {
                                          selectedCountry = newCountry;
                                          phoneController.clear();
                                        });
                                      }
                                    },
                                    dropdownColor: Colors.white,
                                    underline: const SizedBox(),
                                  ),
                                ),
                                inputFormatters: [
                                  MaskTextInputFormatter(
                                    mask: selectedCountry?.mask,
                                    filter: {"#": RegExp(r'[0-9]')},
                                    initialText: phoneController.text,
                                  ),
                                ],
                                hintText:
                                    selectedCountry?.mask.replaceAll('#', '_'),
                                onChanged: (value) {
                                  checkAllowTapButton();
                                },
                              ),
                            ),
                          ],
                        ),
                        const Gap(16),
                        _buildLabel('Адрес'),
                        _buildInputField(
                            controller: addressController, hint: 'Адрес'),
                        const Gap(16),
                        _buildLabel('Ссылка на сайт'),
                        _buildInputField(
                            controller: linkController, hint: 'https://...'),
                        const Gap(32),
                        _buildSubmitButton(isLoading),
                      ],
                    ),
                  ),
                ),
                if (isLoading) const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.mainColor, width: 3),
                  ),
                  child: avatarFile != null
                      ? Image.file(avatarFile!, fit: BoxFit.cover)
                      : ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: widget.company.displayImage,
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.business, size: 50),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                Positioned(
                  right: 15,
                  top: 15,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.mainColor,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.edit, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          Text(
              nameController.text.isEmpty
                  ? 'Название компании'
                  : nameController.text,
              style: AppTextStyles.fs18w700),
        ],
      ),
    );
  }

  // Универсальный метод ввода, поддерживающий форматтеры (как в твоих других формах)
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
  }) {
    return SizedBox(
      height: 44,
      child: CustomTextField(
        controller: controller,
        hintText: hint,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters, // Теперь проброшено верно
        onChanged: (text) {
          if (onChanged != null) onChanged(text);
          checkAllowTapButton();
        },
        textStyle: AppTextStyles.fs14w500,
        fillColor: const Color(0xFFF4F4F4),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildLabel(String text) => Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AppTextStyles.fs14w500));

  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (allowTapButton && !isLoading)
            ? () {
                final rawNumber =
                    phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
                final fullPhone = '${selectedCountry?.code}$rawNumber';

                context.read<EditCompanyCubit>().updateCompany(
                      companyId: widget.company.id!,
                      name: nameController.text,
                      address: addressController.text,
                      phone: fullPhone,
                      websiteUrl: linkController.text,
                      cityId: cityId ?? 0,
                      catalogId: categoryId ?? 0,
                      subCatalogId: subCategoryId,
                      logoFile: avatarFile,
                    );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              allowTapButton ? AppColors.mainColor : Colors.grey.shade400,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white))
            : const Text('Сохранить изменения',
                style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
