import 'package:coment_app/src/feature/catalog/data/catalog_repository.dart';
import 'package:coment_app/src/feature/main/model/feedback_dto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_feedback_cubit.freezed.dart';

class UserFeedbackCubit extends Cubit<UserFeedbackState> {
  UserFeedbackCubit({
    required ICatalogRepository repository,
  })  : _repository = repository,
        super(const UserFeedbackState.initial());

  final ICatalogRepository _repository;

  Future<void> userFeedback({
    required int id,
    required String isView,
    bool hasLoading = false,
    bool hasDelay = false,
  }) async {
    try {
      if (hasLoading) {
        emit(const UserFeedbackState.loading());
      }
      if (hasDelay) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final response = await _repository.userFeedback(id: id, isView: isView);

      if (isClosed) return;

      emit(UserFeedbackState.loaded(feedbackDTO: response));
    } catch (e) {
      emit(UserFeedbackState.error(message: e.toString()));
    }
  }
}

@freezed
class UserFeedbackState with _$UserFeedbackState {
  const factory UserFeedbackState.initial() = _InitialState;

  const factory UserFeedbackState.loading() = _LoadingState;

  const factory UserFeedbackState.loaded({
    required FeedbackDTO feedbackDTO,
  }) = _LoadedState;

  const factory UserFeedbackState.error({
    required String message,
  }) = _ErrorState;
}
