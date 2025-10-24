import 'package:coment_app/src/feature/catalog/data/catalog_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'reply_comment_cubit.freezed.dart';

class ReplyCommentCubit extends Cubit<ReplyCommentState> {
  final ICatalogRepository _repository;
  ReplyCommentCubit({
    required ICatalogRepository repository,
  })  : _repository = repository,
        super(const ReplyCommentState.initial());

  Future<void> writeReplyComment({required int feedbackId, required String comment, int? parentId}) async {
    try {
      emit(const ReplyCommentState.loading());

      await _repository.replyFeedback(feedbackId: feedbackId, comment: comment, parentId: parentId);
      emit(const ReplyCommentState.loaded());
    } catch (e) {
      emit(ReplyCommentState.error(message: e.toString()));
    }
  }
}

@freezed
class ReplyCommentState with _$ReplyCommentState {
  const factory ReplyCommentState.initial() = _InitialState;
  const factory ReplyCommentState.loading() = _LoadingState;
  const factory ReplyCommentState.loaded() = _LoadedState;
  const factory ReplyCommentState.error({required String message}) = _ErrorState;
}
