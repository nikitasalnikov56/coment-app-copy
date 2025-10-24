import 'package:coment_app/src/feature/catalog/data/catalog_repository.dart';
import 'package:coment_app/src/feature/main/model/product_dto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_product_list_cubit.freezed.dart';

class SearchProductListCubit extends Cubit<SearchProductListState> {
  SearchProductListCubit({
    required ICatalogRepository repository,
  })  : _repository = repository,
        super(const SearchProductListState.initial());
  final ICatalogRepository _repository;

  Future<void> getSearchProductList({
    required String search,
    bool hasLoading = false,
    bool hasDelay = false,
  }) async {
    try {
      if (hasLoading) {
        emit(const SearchProductListState.loading());
      }
      if (hasDelay) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final result = await _repository.searchProductList(search: search);

      if (isClosed) return;

      emit(SearchProductListState.loaded(data: result));
    } catch (e) {
      emit(
        SearchProductListState.error(
          message: e.toString(),
        ),
      );
    }
  }
}

@freezed
class SearchProductListState with _$SearchProductListState {
  const factory SearchProductListState.initial() = _InitialState;

  const factory SearchProductListState.loading() = _LoadingState;

  const factory SearchProductListState.loaded({
    required List<ProductDTO> data,
  }) = _LoadedState;

  const factory SearchProductListState.error({
    required String message,
  }) = _ErrorState;
}
