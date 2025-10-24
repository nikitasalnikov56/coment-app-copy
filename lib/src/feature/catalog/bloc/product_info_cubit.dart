import 'package:coment_app/src/feature/catalog/data/catalog_repository.dart';
import 'package:coment_app/src/feature/main/model/product_dto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_info_cubit.freezed.dart';

class ProductInfoCubit extends Cubit<ProductInfoState> {
  ProductInfoCubit({
    required ICatalogRepository repository,
  })  : _repository = repository,
        super(const ProductInfoState.initial());

  final ICatalogRepository _repository;

  Future<void> getProductInfo({
    required int id,
    bool hasLoading = true,
    bool hasDelay = true,
  }) async {
    try {
      if (hasLoading) {
        emit(const ProductInfoState.loading());
      }
      if (hasDelay) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final response = await _repository.productInfo(id: id);

      if (isClosed) return;

      emit(ProductInfoState.loaded(data: response));
    } catch (e) {
      emit(ProductInfoState.error(message: e.toString()));
    }
  }
}

@freezed
class ProductInfoState with _$ProductInfoState {
  const factory ProductInfoState.initial() = _InitialState;

  const factory ProductInfoState.loading() = _LoadingState;

  const factory ProductInfoState.loaded({
    required ProductDTO data,
  }) = _LoadedState;

  const factory ProductInfoState.error({
    required String message,
  }) = _ErrorState;
}
