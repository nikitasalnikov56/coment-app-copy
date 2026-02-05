// lib/src/feature/chat/bloc/chat_cubit.dart
import 'dart:async';

import 'package:coment_app/src/feature/chat/data/chat_repository.dart';
import 'package:coment_app/src/feature/chat/model/chat_message_dto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_cubit.freezed.dart';

class ChatCubit extends Cubit<ChatState> {
  final IChatRepository _repository;
  final int _companyId;
  final String _token;
   late final StreamSubscription _messagesSubscription;

  ChatCubit(this._repository, this._companyId, this._token) : super(const ChatState.initial()) {
    _repository.connectToChat(_companyId, _token);
    _messagesSubscription = _listenToMessages();
  }
    Stream<List<ChatMessageDTO>> get messagesStream => _repository.getMessagesStream(_companyId);

  StreamSubscription _listenToMessages() {
   return _repository.getMessagesStream(_companyId).listen((messages) {
      emit(ChatState.loaded(messages));
    }, onError: (error) {
      emit(ChatState.error(error.toString()));
    });
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    try {
      await _repository.sendMessage( content);
    } catch (e) {
      emit(ChatState.error(e.toString()));
    }
  }

  // 🔥 КЛЮЧЕВОЙ МОМЕНТ: ЗАКРЫВАЕМ ВСЁ ПРИ УНИЧТОЖЕНИИ CUBIT
  @override
  Future<void> close() {
    _messagesSubscription.cancel(); // Отписываемся от стрима
    _repository.disconnect(); // Закрываем WebSocket
    // ⚠️ НЕ вызываем _repository.dispose() здесь, если репозиторий используется где-то ещё!
    return super.close();
  }
}

@freezed
class ChatState with _$ChatState {
  const factory ChatState.initial() = _Initial;
  const factory ChatState.loading() = _Loading;
  const factory ChatState.loaded(List<ChatMessageDTO> messages) = _Loaded;
  const factory ChatState.error(String message) = _Error;
}