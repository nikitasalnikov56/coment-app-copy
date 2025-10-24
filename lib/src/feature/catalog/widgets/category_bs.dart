import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/theme/resources.dart';

class CategoryBs extends StatefulWidget {
  const CategoryBs({super.key});

  static Future<String?> show(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CategoryBs(),
    );
  }

  @override
  State<CategoryBs> createState() => _CategoryBsState();
}

class _CategoryBsState extends State<CategoryBs> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader('Выбрать категорию'),
            const SizedBox(height: 8),
            _buildCategoryTile('Образование', 'Образование'),
            _buildCategoryTile('Гостиницы и общественное питание',
                'Гостиницы и общественное питание'),
            _buildCategoryTile('Финансы', 'Финансы'),
            _buildCategoryTile(
                'Торговля и развлечения', 'Торговля и развлечения'),
            _buildCategoryTile('Медицина', 'Медицина'),
            _buildCategoryTile("Недвижимость и юридические услуги",
                "Недвижимость и юридические услуги"),
                _buildCategoryTile("Техника", "Техника"),
            const SizedBox(height: 32),
            _buildSubmitButton(),
            
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.fs18w700,
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(_selectedCategory),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildCategoryTile(String CategoryName, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.btnGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              _selectCategory(value);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      CategoryName,
                      style: AppTextStyles.fs14w500,
                    ),
                  ),
                  SvgPicture.asset(
                    _selectedCategory == value
                        ? AssetsConstants.icRadioBtnActive
                        : AssetsConstants.icRadioBtn,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        onPressed: () {
          
          Navigator.of(context).pop(_selectedCategory);
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.mainColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text(
          'Выбрать',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _selectCategory(String Category) {
    setState(() {
      _selectedCategory = Category;
    });
  }
}
