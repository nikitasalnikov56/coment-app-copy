// lib/src/feature/chat/bloc/chat_cubit.dart
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:coment_app/src/feature/chat/data/chat_repository.dart';
import 'package:coment_app/src/feature/chat/data/file_repository.dart';
import 'package:coment_app/src/feature/chat/model/chat_message_dto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_cubit.freezed.dart';

class ChatCubit extends Cubit<ChatState> {
  final IChatRepository _repository;
  final IFileRepository _fileRepository;
  final int conversationId;
  final String _token;

  late final StreamSubscription _messagesSubscription;

  // int get conversationId => _companyId;

  ChatCubit(
      this._repository, this._fileRepository, this.conversationId, this._token)
      : super(const ChatState.initial()) {
    _repository.connectToChat(conversationId, _token);
    _messagesSubscription = _listenToMessages();
  }
  IChatRepository get repository => _repository;
  Stream<List<ChatMessageDTO>> get messagesStream =>
      _repository.getMessagesStream(conversationId);
  List<ChatMessageDTO> get currentMessages => state.maybeMap(
        loaded: (s) => s.messages,
        orElse: () => _repository.currentMessages,
      );

  Set<int> get selectedIds => state.maybeMap(
        loaded: (s) => s.selectedIds,
        orElse: () => {},
      );

  ChatMessageDTO? get replyMessage => state.maybeMap(
        loaded: (s) => s.replyMessage,
        orElse: () => null,
      );
// ---------------------------------------
  // === ЛОГИКА ВЫДЕЛЕНИЯ ===
  void toggleSelection(int messageId) {
    state.mapOrNull(loaded: (state) {
      final newSet = Set<int>.from(state.selectedIds);
      if (newSet.contains(messageId)) {
        newSet.remove(messageId);
      } else {
        newSet.add(messageId);
      }
      emit(state.copyWith(selectedIds: newSet));
    });
  }

  void clearSelection() {
    state.mapOrNull(loaded: (state) {
      emit(state.copyWith(selectedIds: {}, replyMessage: null));
    });
  }

  // === ЛОГИКА ОТВЕТА ===
  void setReplyMessage(ChatMessageDTO message) {
    state.mapOrNull(loaded: (state) {
      // Сбрасываем выделение и устанавливаем ответ
      emit(state.copyWith(selectedIds: {}, replyMessage: message));
    });
  }

  void cancelReply() {
    state.mapOrNull(loaded: (state) {
      emit(state.copyWith(replyMessage: null));
    });
  }
  // -------------------------------------

  void checkConnection() {
    // Вызываем метод репозитория для проверки/восстановления связи
    _repository.ensureConnection();
  }

  StreamSubscription _listenToMessages() {
    return _repository.getMessagesStream(conversationId).listen((messages) {
      final currentSelected = selectedIds;
      final currentReply = replyMessage;
      emit(ChatState.loaded(
        messages,
        selectedIds: currentSelected,
        replyMessage: currentReply,
      ));
    }, onError: (error) {
      emit(ChatState.error(error.toString()));
    });
  }

  Future<void> sendMessage(String content, {List<File>? files}) async {
    if (content.trim().isEmpty && (files == null || files.isEmpty)) return;
    final replyToId = replyMessage?.id;
    // state.mapOrNull(loaded: (s) => replyToId = s.replyMessage?.id);
    try {
      List<String>? attachmentUrls;
      if (files != null && files.isNotEmpty) {
        log('[ChatCubit] Начинаю загрузку ${files.length} файлов...');

        try {
          attachmentUrls = await _fileRepository.uploadChatFiles(files);
          log('[ChatCubit] Файлы успешно загружены: $attachmentUrls');
        } catch (e, stack){
          log('[ChatCubit] КРИТИЧЕСКАЯ ОШИБКА ЗАГРУЗКИ ФАЙЛОВ: $e');
        log('[ChatCubit] StackTrace: $stack');
        // Если загрузка файлов упала, мы не должны отправлять пустое сообщение со ссылками
        rethrow;
        }
      }
      await _repository.sendMessage(
        content,
        replyToId: replyToId,
        attachments: attachmentUrls,
      );
      cancelReply();
    } catch (e) {
      emit(ChatState.error(e.toString()));
    }
  }

  // === НОВЫЙ МЕТОД ДЛЯ АУДИО ===
  Future<void> sendVoiceMessage(String url, int durationMs) async {
    // Получаем ID сообщения, на которое отвечаем (если есть)
    final replyToId = replyMessage?.id;

    try {
      // Вызываем обновленный метод репозитория.
      // Текст оставляем пустым, а url передаем в voiceUrl.
      await _repository.sendMessage(
        "",
        replyToId: replyToId,
        voiceUrl: url,
        voiceDuration: durationMs,
      );

      // Сбрасываем состояние ответа после успешной отправки
      cancelReply();
    } catch (e) {
      log("Ошибка отправки голосового сообщения: $e");
      emit(ChatState.error(e.toString()));
    }
  }

  // 🔥 КЛЮЧЕВОЙ МОМЕНТ: ЗАКРЫВАЕМ ВСЁ ПРИ УНИЧТОЖЕНИИ CUBIT
  @override
  Future<void> close() {
    _messagesSubscription.cancel(); // Отписываемся от стрима
    // _repository.disconnect(); // Закрываем WebSocket
    _repository.leaveChat(); // Закрываем WebSocket
    // ⚠️ НЕ вызываем _repository.dispose() здесь, если репозиторий используется где-то ещё!
    return super.close();
  }

  // === УДАЛЕНИЕ ===
  void deleteSelectedMessages() {
    state.mapOrNull(loaded: (state) {
      if (state.selectedIds.isEmpty) return;
      // Вызываем метод репозитория
      _repository.deleteMessages(state.selectedIds.toList());
      // Очищаем выделение сразу
      clearSelection();
    });
  }

// В ChatCubit (lib/src/feature/chat/bloc/chat_cubit.dart)

  Future<void> forwardSelectedMessages(int targetConversationId) async {
    state.mapOrNull(loaded: (s) async {
      if (s.selectedIds.isEmpty) return;

      // Собираем текст всех выделенных сообщений
      final messagesToForward = s.messages
          .where((m) => s.selectedIds.contains(m.id))
          .toList()
        ..sort((a, b) =>
            a.createdAt.compareTo(b.createdAt)); // Сортируем по времени

      for (final msg in messagesToForward) {
        try {
          // Отправляем в репозиторий, но указываем ID другого чата
          // (Нужно убедиться, что sendMessage в репозитории принимает conversationId)
          await _repository.sendMessage(
            msg.content,
            targetConversationId: targetConversationId,
            // Здесь можно добавить флаг 'isForwarded: true', если бэкенд поддерживает
          );
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          log("Error forwarding message ${msg.id}: $e");
        }
      }

      clearSelection();
    });
  }
}

@freezed
class ChatState with _$ChatState {
  const factory ChatState.initial() = _Initial;
  const factory ChatState.loading() = _Loading;
  const factory ChatState.loaded(
    List<ChatMessageDTO> messages, {
    @Default({}) Set<int> selectedIds,
    ChatMessageDTO? replyMessage,
    @Default(false) bool isUploading,
  }) = _Loaded;
  const factory ChatState.error(String message) = _Error;
}
