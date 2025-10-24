import 'package:coment_app/src/feature/main/data/main_repository.dart';
import 'package:coment_app/src/feature/main/model/product_dto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_list_cubit.freezed.dart';

class ProductListCubit extends Cubit<ProductListState> {
  ProductListCubit({
    required IMainRepository repository,
  })  : _repository = repository,
        super(const ProductListState.initial());
  final IMainRepository _repository;

  Future<void> getProductList({
    required int subcatalogId,
    String? sort,
    int? cityId,
    int? countryId,
  }) async {
    try {
      emit(const ProductListState.loading());

      final result =
          await _repository.productList(subcatalogId: subcatalogId, sort: sort, cityId: cityId, countryId: countryId);

      if (isClosed) return;

      emit(ProductListState.loaded(data: result));
    } catch (e) {
      emit(
        ProductListState.error(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> getPopularProductList({int? cityId}) async {
    try {
      emit(const ProductListState.loading());

      final result = await _repository.popularProductList(cityId: cityId);

      if (isClosed) return;

      emit(ProductListState.loaded(data: result));
    } catch (e) {
      emit(
        ProductListState.error(
          message: e.toString(),
        ),
      );
    }
  }
}

@freezed
class ProductListState with _$ProductListState {
  const factory ProductListState.initial() = _InitialState;

  const factory ProductListState.loading() = _LoadingState;

  const factory ProductListState.loaded({
    required List<ProductDTO> data,
  }) = _LoadedState;

  const factory ProductListState.error({
    required String message,
  }) = _ErrorState;
}
