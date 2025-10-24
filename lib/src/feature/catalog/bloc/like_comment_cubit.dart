import 'package:coment_app/src/feature/catalog/data/catalog_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'like_comment_cubit.freezed.dart';

class LikeCommentCubit extends Cubit<LikeCommentState> {
  final ICatalogRepository _repository;
  LikeCommentCubit({
    required ICatalogRepository repository,
  })  : _repository = repository,
        super(const LikeCommentState.initial());

  Future<void> likeComment({required int feedbackId, required String type}) async {
    try {
      emit(const LikeCommentState.loading());

      await _repository.like(feedbackId: feedbackId, type: type);
      emit(const LikeCommentState.loadedLike());
    } catch (e) {
      emit(LikeCommentState.error(message: e.toString()));
    }
  }

  Future<void> dislikeComment({required int feedbackId}) async {
    try {
      emit(const LikeCommentState.loading());

      await _repository.dislike(feedbackId: feedbackId);
      emit(const LikeCommentState.loadedDislike());
    } catch (e) {
      emit(LikeCommentState.error(message: e.toString()));
    }
  }
}

@freezed
class LikeCommentState with _$LikeCommentState {
  const factory LikeCommentState.initial() = _InitialState;
  const factory LikeCommentState.loading() = _LoadingState;
  const factory LikeCommentState.loadedLike() = _LoadedLikeState;
  const factory LikeCommentState.loadedDislike() = _LoadedDislikeState;
  const factory LikeCommentState.error({required String message}) = _ErrorState;
}
