import 'dart:developer';

import 'package:coment_app/src/feature/chat/data/chat_repository.dart';
import 'package:coment_app/src/feature/chat/model/chat_message_dto.dart';
import 'package:coment_app/src/feature/chat/model/conversation_dto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversations_cubit.freezed.dart';

class ConversationsCubit extends Cubit<ConversationsState> {
  final IChatRepository _repository;
  String? _token;
  ConversationsCubit(this._repository)
      : super(const ConversationsState.initial());

  Future<void> loadConversations(String token, {bool silent = false}) async {
    if (!silent) {
      emit(const ConversationsState.loading());
    }
    _token = token;
    try {
      final conversations = await _repository.findConversationsForUser(token);
      emit(ConversationsState.loaded(conversations));
    } catch (e) {
      emit(ConversationsState.error(e.toString()));
    }
  }

  void updateConversationWithNewMessage(ChatMessageDTO message) {
    log("🟡 [Cubit] Вызван update для чата: ${message.conversationId}");
    // 1. Если прилетел наш флаг "REFRESH_LIST" или id == -1
    if (message.id == -1 || message.content == 'REFRESH_LIST') {
      final token = _token;
      if (token != null) {
        log("🔄 [Cubit] Получен сигнал удаления, обновляю список чатов...");
        loadConversations(token, silent: true);
      }
      return;
    }
    state.maybeWhen(
      loaded: (conversations) {
        bool chatFound = false;
        final updatedList = conversations.map((conv) {
          if (conv.id == message.conversationId) {
            chatFound = true;
            log("🔵 [Cubit] Чат найден! Старый unreadCount: ${conv.unreadCount}. Делаем +1");
            // Создаем копию чата с обновленными данными
            return conv.copyWith(
              lastMessage: message,
              lastMessageDate: message.createdAt,
              unreadCount: conv.unreadCount + 1, // Добавляем +1 к непрочитанным
            );
          }
          return conv;
        }).toList();
        if (!chatFound) {
          log("🔴 [Cubit] ОШИБКА: Чат ${message.conversationId} не найден в текущем списке!");
        }
        // Сортируем список, чтобы чат с новым сообщением прыгнул на самый верх
        updatedList.sort((a, b) {
          final dateA =
              a.lastMessageDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          final dateB =
              b.lastMessageDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          return dateB.compareTo(dateA); // По убыванию (свежие сверху)
        });
        log("🟣 [Cubit] Эмитим новое состояние (loaded)");
        emit(ConversationsState.loaded(updatedList));
      },
      orElse: () {
        log("🔴 [Cubit] Ошибка: состояние не loaded! Сейчас: $state");
      },
    );
  }
}

@freezed
class ConversationsState with _$ConversationsState {
  const factory ConversationsState.initial() = _Initial;
  const factory ConversationsState.loading() = _Loading;
  const factory ConversationsState.loaded(List<ConversationDTO> conversations) =
      _Loaded;
  const factory ConversationsState.error(String message) = _Error;
}
