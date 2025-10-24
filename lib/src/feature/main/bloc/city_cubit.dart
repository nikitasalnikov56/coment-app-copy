import 'package:coment_app/src/feature/main/data/main_repository.dart';
import 'package:coment_app/src/feature/main/model/main_dto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'city_cubit.freezed.dart';

class CityCubit extends Cubit<CityState> {
  CityCubit({
    required IMainRepository repository,
  })  : _repository = repository,
        super(const CityState.initial());
  final IMainRepository _repository;

  Future<void> getCityList({
    required int countryId,
  }) async {
    try {
      emit(const CityState.loading());

      final result = await _repository.cityList(countryId: countryId);

      if (isClosed) return;

      emit(CityState.loaded(response: result));
    } catch (e) {
      emit(
        CityState.error(
          message: e.toString(),
        ),
      );
    }
  }
}

@freezed
class CityState with _$CityState {
  const factory CityState.initial() = _InitialState;

  const factory CityState.loading() = _LoadingState;

  const factory CityState.loaded({
    required List<CityDTO> response,
  }) = _LoadedState;

  const factory CityState.error({
    required String message,
  }) = _ErrorState;
}
