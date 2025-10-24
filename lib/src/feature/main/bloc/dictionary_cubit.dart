import 'package:coment_app/src/feature/main/data/main_repository.dart';
import 'package:coment_app/src/feature/main/model/main_dto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dictionary_cubit.freezed.dart';

class DictionaryCubit extends Cubit<DictionaryState> {
  DictionaryCubit({
    required IMainRepository repository,
  })  : _repository = repository,
        super(const DictionaryState.initial());
  final IMainRepository _repository;

  Future<void> getDictionary() async {
    try {
      emit(const DictionaryState.loading());

      final result = await _repository.dictionary();

      if (isClosed) return;

      emit(DictionaryState.loaded(mainDTO: result));
    } catch (e) {
      emit(
        DictionaryState.error(
          message: e.toString(),
        ),
      );
    }
  }
}

@freezed
class DictionaryState with _$DictionaryState {
  const factory DictionaryState.initial() = _InitialState;

  const factory DictionaryState.loading() = _LoadingState;

  const factory DictionaryState.loaded({
    required MainDTO mainDTO,
  }) = _LoadedState;

  const factory DictionaryState.error({
    required String message,
  }) = _ErrorState;
}
