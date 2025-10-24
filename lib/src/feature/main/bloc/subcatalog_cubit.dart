import 'package:coment_app/src/feature/main/data/main_repository.dart';
import 'package:coment_app/src/feature/main/model/main_dto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subcatalog_cubit.freezed.dart';

class SubcatalogCubit extends Cubit<SubcatalogState> {
  SubcatalogCubit({
    required IMainRepository repository,
  })  : _repository = repository,
        super(const SubcatalogState.initial());
  final IMainRepository _repository;

  Future<void> getSubcatalogList({required int catalogId}) async {
    try {
      emit(const SubcatalogState.loading());

      final result = await _repository.subcatalogList(catalogId: catalogId);

      if (isClosed) return;

      emit(SubcatalogState.loaded(response: result));
    } catch (e) {
      emit(
        SubcatalogState.error(
          message: e.toString(),
        ),
      );
    }
  }
}

@freezed
class SubcatalogState with _$SubcatalogState {
  const factory SubcatalogState.initial() = _InitialState;

  const factory SubcatalogState.loading() = _LoadingState;

  const factory SubcatalogState.loaded({
    required List<SubCatalogDTO> response,
  }) = _LoadedState;

  const factory SubcatalogState.error({
    required String message,
  }) = _ErrorState;
}
