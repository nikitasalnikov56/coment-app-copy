
import 'dart:io';

import 'package:coment_app/src/feature/catalog/data/catalog_repository.dart';
import 'package:coment_app/src/feature/catalog/model/feedback_payload.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'leave_feedback_cubit.freezed.dart';

class LeaveFeedbackCubit extends Cubit<LeaveFeedbackState> {
  final ICatalogRepository _repository;
  LeaveFeedbackCubit({
    required ICatalogRepository repository,
  })  : _repository = repository,
        super(const LeaveFeedbackState.initial());

  Future<void> createFeedback({
    required FeedbackPayload feedbackPayload,
    List<File>? image,
  }) async {
    try {
      emit(const LeaveFeedbackState.loading());

      final response = await _repository.createFeedback(
          feedbackPayload: feedbackPayload, image: image);


      final wasToxic = response['wasToxic'] == true;

      final int warningCount = (response['warningCount'] as num?)?.toInt() ?? 0;


      final String? text = response['text'] as String?;


      if (text != null &&
          [
            'Комментарий удалён',
            'Comment removed',
            'Izoh o\'chirildi',
            'Пікір жойылды'
          ].any((word) => text.contains(word))) {
        emit(const LeaveFeedbackState.hidden());
      } else if (wasToxic) {
        emit(LeaveFeedbackState.loaded(
            wasToxic: true, warningCount: warningCount));
        // emit(const LeaveFeedbackState.toxicWarning());
      } else {
        emit(const LeaveFeedbackState.loaded(wasToxic: false, warningCount: 0));
      }
      // emit(const LeaveFeedbackState.loaded());
    } catch (e) {
      emit(LeaveFeedbackState.error(message: e.toString()));
    }
  }
}

@freezed
class LeaveFeedbackState with _$LeaveFeedbackState {
  const factory LeaveFeedbackState.initial() = _InitialState;
  const factory LeaveFeedbackState.loading() = _LoadingState;
  const factory LeaveFeedbackState.loaded({
    required bool wasToxic,
    required int warningCount,
  }) = _LoadedState;
  const factory LeaveFeedbackState.hidden() = _Hidden;
  // const factory LeaveFeedbackState.toxicWarning() = _ToxicWarning;
  // const factory LeaveFeedbackState.toxicWithAdminReview() =
  //     _ToxicWithAdminReview;
  const factory LeaveFeedbackState.error({required String message}) =
      _ErrorState;
}
