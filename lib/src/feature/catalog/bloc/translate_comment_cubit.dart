import 'package:coment_app/src/feature/catalog/data/catalog_repository.dart';
import 'package:coment_app/src/feature/catalog/presentation/widgets/translate_comment_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'translate_comment_cubit.freezed.dart';

class TranslateCommentCubit extends Cubit<TranslateCommentState> {
  final ICatalogRepository _repository;

  TranslateCommentCubit(this._repository) : super(const TranslateCommentState.initial());

  Future<void> translate({
    required int id,
    required String targetLang,
    required TranslateType type,
  }) async {
    try {
      emit(const TranslateCommentState.loading());

      Map<String, dynamic> response;
      if (type == TranslateType.reply) {
        response = await _repository.translateReply(replyId: id, targetLang: targetLang);
      } else {
        response = await _repository.translateReview(reviewId: id, targetLang: targetLang);
      }

      final translatedText = response['translatedText'] as String;
      emit(TranslateCommentState.loaded(translatedText: translatedText));
    } catch (e) {
      emit(TranslateCommentState.error(message: e.toString()));
    }
  }
}

@freezed
class TranslateCommentState with _$TranslateCommentState {
  const factory TranslateCommentState.initial() = _Initial;
  const factory TranslateCommentState.loading() = _Loading;
  const factory TranslateCommentState.loaded({required String translatedText}) = _Loaded;
  const factory TranslateCommentState.error({required String message}) = _Error;
}