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

  Future<void> writeTechSupport({
    required String subject,
    required String message,
    required String category,
    required String contactEmail,
  }) async {
    try {
      emit(const TechSupportState.loading());

      final response = await _repository.writeTechSupport(
        subject: subject,
        message: message,
        category: category,
        contactEmail: contactEmail,
      );
      final messageResponse = response.message;
      if (messageResponse == null) {
        // Обработка случая, если message отсутствует (маловероятно, но безопасно)
       emit( const TechSupportState.error (message: 'Ответ от сервера не содержит сообщения'));
      }
      emit(TechSupportState.loaded(message: messageResponse.toString()));
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
  const factory TechSupportState.loaded({required String message}) =
      _LoadedState;
  const factory TechSupportState.error({required String message}) = _ErrorState;
}
