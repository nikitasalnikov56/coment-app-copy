import 'dart:io';

import 'package:flutter/material.dart';

class CreateProductModel extends ChangeNotifier {
  int? _categoryId;
  String? _categoryTitle;
  int? _subCategoryId;
  String? _subCategoryTitle;
  String? _productName;
  String? _address;
  String? _phoneNumber;
  String? _link;
  int? _countryId;
  String? _countryTitle;
  int? _cityId;
  String? _cityTitle;
  List<File>? _productImages;
  int? _rating;
  String? _feedbackText;
  List<File>? _feedbackImages;

  ///
  /// `get`
  ///
  int? get categoryId => _categoryId;
  String? get categoryTitle => _categoryTitle;
  int? get subCategoryId => _subCategoryId;
  String? get subCategoryTitle => _subCategoryTitle;
  String? get productName => _productName;
  String? get address => _address;
  String? get phoneNumber => _phoneNumber;
  String? get link => _link;
  int? get countryId => _countryId;
  String? get countryTitle => _countryTitle;
  int? get cityId => _cityId;
  String? get cityTitle => _cityTitle;
  List<File>? get productImages => _productImages;
  int? get rating => _rating;
  String? get feedbackText => _feedbackText;
  List<File>? get feedbackImages => _feedbackImages;

  ///
  /// `set`
  ///
  set categoryId(int? value) {
    _categoryId = value;
    notifyListeners();
  }

  set categoryTitle(String? value) {
    _categoryTitle = value;
    notifyListeners();
  }

  set subCategoryId(int? value) {
    _subCategoryId = value;
    notifyListeners();
  }

  set subCategoryTitle(String? value) {
    _subCategoryTitle = value;
    notifyListeners();
  }

  set productName(String? value) {
    _productName = value;
    notifyListeners();
  }

  set address(String? value) {
    _address = value;
    notifyListeners();
  }

  set phoneNumber(String? value) {
    _phoneNumber = value;
    notifyListeners();
  }

  set link(String? value) {
    _link = value;
    notifyListeners();
  }

  set countryId(int? value) {
    _countryId = value;
    notifyListeners();
  }

  set countryTitle(String? value) {
    _countryTitle = value;
    notifyListeners();
  }

  set cityId(int? value) {
    _cityId = value;
    notifyListeners();
  }

  set cityTitle(String? value) {
    _cityTitle = value;
    notifyListeners();
  }

  set productImages(List<File>? value) {
    _productImages = value;
    notifyListeners();
  }

  set rating(int? value) {
    _rating = value;
    notifyListeners();
  }

  set feedbackText(String? value) {
    _feedbackText = value;
    notifyListeners();
  }

  set feedbackImages(List<File>? value) {
    _feedbackImages = value;
    notifyListeners();
  }
}
