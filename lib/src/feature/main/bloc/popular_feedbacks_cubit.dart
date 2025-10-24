import 'package:coment_app/src/feature/main/data/main_repository.dart';
import 'package:coment_app/src/feature/main/model/feedback_dto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'popular_feedbacks_cubit.freezed.dart';

class PopularFeedbacksCubit extends Cubit<PopularFeedbacksState> {
  PopularFeedbacksCubit({
    required IMainRepository repository,
  })  : _repository = repository,
        super(const PopularFeedbacksState.initial());
  final IMainRepository _repository;

  Future<void> getPopularFeedbacks({int? cityId}) async {
    try {
      emit(const PopularFeedbacksState.loading());

      final result = await _repository.popularFeedbackList(cityId: cityId);

      if (isClosed) return;

      emit(PopularFeedbacksState.loaded(data: result));
    } catch (e) {
      emit(
        PopularFeedbacksState.error(
          message: e.toString(),
        ),
      );
    }
  }
}

@freezed
class PopularFeedbacksState with _$PopularFeedbacksState {
  const factory PopularFeedbacksState.initial() = _InitialState;

  const factory PopularFeedbacksState.loading() = _LoadingState;

  const factory PopularFeedbacksState.loaded({
    required List<FeedbackDTO> data,
  }) = _LoadedState;

  const factory PopularFeedbacksState.error({
    required String message,
  }) = _ErrorState;
}
