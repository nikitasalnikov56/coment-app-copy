import 'package:coment_app/src/feature/main/model/feedback_dto.dart';
import 'package:coment_app/src/feature/profile/data/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_feedbacks_cubit.freezed.dart';

class MyFeedbacksCubit extends Cubit<MyFeedbacksState> {
  MyFeedbacksCubit({
    required IProfileRepository repository,
  })  : _repository = repository,
        super(const MyFeedbacksState.initial());

  final IProfileRepository _repository;

  Future<void> getMyFeedbacks({
    bool hasLoading = false,
    bool hasDelay = false,
  }) async {
    try {
      if (hasLoading) {
        emit(const MyFeedbacksState.loading());
      }
      if (hasDelay) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final result = await _repository.myFeedbacks();

      if (isClosed) return;

      emit(MyFeedbacksState.loaded(data: result));
    } catch (e) {
      emit(MyFeedbacksState.error(message: e.toString()));
    }
  }
}

@freezed
class MyFeedbacksState with _$MyFeedbacksState {
  const factory MyFeedbacksState.initial() = _InitialState;

  const factory MyFeedbacksState.loading() = _LoadingState;

  const factory MyFeedbacksState.loaded({
    required List<FeedbackDTO> data,
  }) = _LoadedState;

  const factory MyFeedbacksState.error({
    required String message,
  }) = _ErrorState;
}
