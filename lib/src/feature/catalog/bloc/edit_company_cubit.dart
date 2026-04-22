import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:coment_app/src/feature/catalog/data/catalog_repository.dart';

part 'edit_company_cubit.freezed.dart';

class EditCompanyCubit extends Cubit<EditCompanyState> {
  final ICatalogRepository _repository; 

  EditCompanyCubit({required ICatalogRepository repository}) 
      : _repository = repository, 
        super(const EditCompanyState.initial());

  Future<void> updateCompany({
    required int companyId,
    required String name,
    required String address,
    required String phone,
    required String websiteUrl,
    required int cityId,
    required int catalogId,
    int? subCatalogId,
    File? logoFile,
  }) async {
    try {
      emit(const EditCompanyState.loading());
      
      // 1. Формируем тело запроса для текстовых данных
      final Map<String, dynamic> updateData = {
        "name": name,
        "address": address,
        "organisation_phone": phone,
        "website_url": websiteUrl,
        "cityId": cityId,
        "catalogId": catalogId,
        "subCatalogId": subCatalogId,
      };

      // 2. Отправляем PUT запрос через репозиторий
      await _repository.updateCompany(
        id: companyId,
        data: updateData,
      );
      
      // 3. Если пользователь выбрал новое фото, отправляем его вторым запросом
      if (logoFile != null) {
        await _repository.uploadCompanyLogo(
          id: companyId,
          image: logoFile,
        );
      }

      emit(const EditCompanyState.success());
    } catch (e) {
      emit(EditCompanyState.error(message: e.toString()));
    }
  }
}

@freezed
class EditCompanyState with _$EditCompanyState {
  const factory EditCompanyState.initial() = _InitialState;
  const factory EditCompanyState.loading() = _LoadingState;
  const factory EditCompanyState.success() = _SuccessState;
  const factory EditCompanyState.error({required String message}) = _ErrorState;
}