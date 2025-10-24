import 'package:coment_app/src/feature/catalog/data/catalog_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'complain_cubit.freezed.dart';

class ComplainCubit extends Cubit<ComplainState> {
  ComplainCubit({
    required ICatalogRepository repository,
  })  : _repository = repository,
        super(const ComplainState.initial());

  final ICatalogRepository _repository;

  Future<void> complain({required String text, required int feedId, required String type}) async {
    try {
      emit(const ComplainState.loading());

      await _repository.complain(text: text, feedId: feedId, type: type);
      emit(const ComplainState.loaded());
    } catch (e) {
      emit(ComplainState.error(message: e.toString()));
    }
  }
}

@freezed
class ComplainState with _$ComplainState {
  const factory ComplainState.initial() = _InitialState;
  const factory ComplainState.loading() = _LoadingState;
  const factory ComplainState.loaded() = _LoadedState;
  const factory ComplainState.error({required String message}) = _ErrorState;
}
