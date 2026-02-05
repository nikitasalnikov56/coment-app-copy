// lib/src/feature/chat/cubit/conversations_cubit.dart
import 'package:coment_app/src/feature/chat/data/chat_repository.dart';
import 'package:coment_app/src/feature/chat/model/conversation_dto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversations_cubit.freezed.dart';


class ConversationsCubit extends Cubit<ConversationsState> {
  final IChatRepository _repository;

  ConversationsCubit(this._repository) : super(const ConversationsState.initial());

  Future<void> loadConversations(String token) async {
    emit(const ConversationsState.loading());
    try {
      final conversations = await _repository.findConversationsForUser(token);
      emit(ConversationsState.loaded(conversations));
    } catch (e) {
      emit(ConversationsState.error(e.toString()));
    }
  }
}

// lib/src/feature/chat/cubit/conversations_state.dart
@freezed
class ConversationsState with _$ConversationsState {
  const factory ConversationsState.initial() = _Initial;
  const factory ConversationsState.loading() = _Loading;
  const factory ConversationsState.loaded(List<ConversationDTO> conversations) = _Loaded;
  const factory ConversationsState.error(String message) = _Error;
}