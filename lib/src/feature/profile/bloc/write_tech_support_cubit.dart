import 'package:coment_app/src/feature/profile/data/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'write_tech_support_cubit.freezed.dart';

class TechSupportCubit extends Cubit<TechSupportState> {
  TechSupportCubit({
    required IProfileRepository repository,
  })  : _repository = repository,
        super(const TechSupportState.initial());

  final IProfileRepository _repository;

  Future<void> writeTechSupport({required String text}) async {
    try {
      emit(const TechSupportState.loading());

      await _repository.writeTechSupport(text: text);

      emit(const TechSupportState.loaded());
    } catch (e) {
      emit(
        TechSupportState.error(
          message: e.toString(),
        ),
      );
    }
  }
}

@freezed
class TechSupportState with _$TechSupportState {
  const factory TechSupportState.initial() = _InitialState;
  const factory TechSupportState.loading() = _LoadingState;
  const factory TechSupportState.loaded() = _LoadedState;
  const factory TechSupportState.error({required String message}) = _ErrorState;
}
