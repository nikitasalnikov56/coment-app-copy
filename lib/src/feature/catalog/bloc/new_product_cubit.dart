import 'dart:io';

import 'package:coment_app/src/feature/catalog/data/catalog_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'new_product_cubit.freezed.dart';

class NewProductCubit extends Cubit<NewProductState> {
  final ICatalogRepository _repository;
  NewProductCubit({
    required ICatalogRepository repository,
  })  : _repository = repository,
        super(const NewProductState.initial());

  Future<void> createNewProduct(
      {required int cityId,
      required int countryId,
      File? image,
      required String name,
      required String address,
      required String organisationPhone,
      required String websiteUrl,
      required int catalogId,
      int? subCatalogId,
      required String comment,
      required int rating,
      List<File>? imageFeedback,
      String? nameSubCatalog}) async {
    try {
      emit(const NewProductState.loading());

      await _repository.createNewProduct(
          cityId: cityId,
          countryId: countryId,
          name: name,
          address: address,
          organisationPhone: organisationPhone,
          websiteUrl: websiteUrl,
          catalogId: catalogId,
          subCatalogId: subCatalogId,
          comment: comment,
          rating: rating,
          image: image,
          imageFeedback: imageFeedback,
          nameSubCatalog: nameSubCatalog);
      emit(const NewProductState.loaded());
    } catch (e) {
      emit(NewProductState.error(message: e.toString()));
    }
  }
}

@freezed
class NewProductState with _$NewProductState {
  const factory NewProductState.initial() = _InitialState;
  const factory NewProductState.loading() = _LoadingState;
  const factory NewProductState.loaded() = _LoadedState;
  const factory NewProductState.error({required String message}) = _ErrorState;
}
