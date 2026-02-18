// lib/src/feature/chat/data/chat_repository_impl.dart
import 'dart:developer';

import 'package:coment_app/src/core/rest_client/rest_client.dart';
import 'package:coment_app/src/feature/auth/models/user_dto.dart';
import 'package:coment_app/src/feature/chat/data/chat_repository.dart';
import 'dart:async';
import 'dart:convert';
import 'package:coment_app/src/core/utils/refined_logger.dart';
import 'package:coment_app/src/feature/chat/model/chat_message_dto.dart';
import 'package:coment_app/src/feature/chat/model/conversation_dto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatRepositoryImpl implements IChatRepository {
  final IRestClient _restClient;
  String? _currentToken;
  int? _currentConversationId;
  int? _currentCompanyId;
  int? _currentUserId;

  // Состояние соединения
  WebSocketChannel? _channel;
  Timer? _pingTimer;

  // final StreamController<List<ChatMessageDTO>> _messagesController = StreamController.broadcast();
  final BehaviorSubject<List<ChatMessageDTO>> _messagesController =
      BehaviorSubject.seeded([]);

// 1. КЭШ СОСТОЯНИЙ: Ключ = ID юзера (int), Значение = Данные статуса
  final Map<int, Map<String, dynamic>> _onlineUsersStatusCache = {};
  Map<int, Map<String, dynamic>> get currentStatusCache =>
      _onlineUsersStatusCache;

// Добавь контроллер для статусов
  final BehaviorSubject<Map<int, Map<String, dynamic>>> _userStatusController =
      BehaviorSubject.seeded({});

// Геттер стрима
  @override
  Stream<Map<int, Map<String, dynamic>>> get userStatusStream =>
      _userStatusController.stream;

// РЕАЛИЗАЦИЯ ГЕТТЕРА для сообщений (чтобы не было ошибки в Cubit)
  List<ChatMessageDTO> get currentMessages => _messagesController.value;
  int? _loadingConversationId;

  ChatRepositoryImpl(this._restClient);

  @override
  Stream<List<ChatMessageDTO>> getMessagesStream(int conversationId) {
    return _messagesController.stream;
  }
  // @override
  // Stream<List<ChatMessageDTO>> getMessagesStream(int conversationId) {
  //   // Мы фильтруем поток: если данные в контроллере относятся к другому ID,
  //   // отдаем пустой список или фильтруем.
  //   return _messagesController.stream.map((messages) {
  //     if (messages.isEmpty) return [];

  //     // Если первое сообщение в списке из другого чата — значит это "грязные" данные
  //     if (messages.first.conversationId != _currentConversationId) {
  //       return [];
  //     }
  //     return messages;
  //   });
  // }

  // Future<List<ChatMessageDTO>> _loadHistory(int companyId, String token) async {
  //   try {
  //     final response = await _restClient.get(
  //       'conversations/$companyId/messages',
  //       headers: {'Authorization': 'Bearer $token'},
  //     );
  //     final items = (response['items'] as List?) ?? [];
  //     final list = <ChatMessageDTO>[];
  //     for (var item in items) {
  //       try {
  //         list.add(ChatMessageDTO.fromJson(item as Map<String, dynamic>));
  //       } catch (e, stack) {
  //         logger.error('Failed to parse message', error: e, stackTrace: stack);
  //         // Пропускаем битое сообщение
  //       }
  //     }
  //     return list;
  //   } catch (e) {
  //     logger.error('Load history failed', error: e);
  //     return [];
  //   }
  // }

  Future<List<ChatMessageDTO>> _loadHistory(
      int conversationId, String token) async {
    try {
      final response = await _restClient.get(
        'conversations/$conversationId/messages',
        headers: {'Authorization': 'Bearer $token'},
      );

      // Твоя логика парсинга...
      final items = (response['items'] as List?) ?? [];
      return items.map((e) => ChatMessageDTO.fromJson(e)).toList();
    } catch (e) {
      log("⚠️ [ChatRepo] Ошибка бэкенда при загрузке истории: $e");
      // Возвращаем пустой список вместо проброса ошибки,
      // чтобы сокеты продолжили работать
      return [];
    }
  }

  void _updateUserStatusInCache(UserDTO user) {
    final userId = user.id;
    if (userId == null) return; // Защита от null

    _onlineUsersStatusCache[user.id!] = {
      'userId': user.id,
      'isOnline': user.isOnline,
      'lastSeen': user.lastSeen,
    };
    _userStatusController.add(Map.from(_onlineUsersStatusCache));
  }

  @override
  Future<void> connectToChat(int conversationId, String token) async {
    _currentConversationId = conversationId; // Теперь это РЕАЛЬНЫЙ ID чата
    _currentToken = token;
    _messagesController.add([]); // Очищаем экран перед загрузкой

    try {
      // 1. Получаем профиль, если его нет (нужно для определения отправителя)
      if (_currentUserId == null) {
        final profile = await _restClient
            .get('auth/profile', headers: {'Authorization': 'Bearer $token'});
        _currentUserId = profile['id'] as int;
      }
      // 2. Сразу подключаем сокет
      await _establishSocketConnection(token);

      // 3. Подписываемся на комнату чата
      _sendJson({
        'event': 'join',
        'data': {'conversationId': conversationId}
      });
      _startPing();

      // 4. Загружаем историю сообщений напрямую по ID чата
      final history = await _loadHistory(conversationId, token);
      _messagesController.add(history);

      log("✅ [ChatRepo] Connected to chat ID: $conversationId");
    } catch (e) {
      log("❌ [ChatRepo] Connection error: $e");
      _messagesController.addError(e);
      rethrow; // Чтобы Cubit увидел ошибку
    }
  }

  Future<void> _establishSocketConnection(String token) async {
    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }

    final uri = Uri(
      scheme: 'wss',
      host: 'abca-94-158-58-248.ngrok-free.app',
      path: '/chat',
      queryParameters: {'token': token},
    );

    _channel = IOWebSocketChannel.connect(
      uri.toString(),
      headers: {'ngrok-skip-browser-warning': 'true'},
      pingInterval: const Duration(seconds: 5),
    );

    _channel!.stream.listen(
      _handleMessage,
      onError: (e) => log("❌ WS Error: $e"),
      onDone: () => log("ℹ️ WS Connection Closed"),
    );
  }

  // void _handleMessage(dynamic data) {
  //   try {
  //     log("WS RAW DATA: $data"); // Логируем всё, чтобы видеть приходят ли ивенты

  //     final message = jsonDecode(data as String);
  //     final event = message['event'];
  //     final msgData = message['data'];

  //     // ЖЕСТКИЙ ФИЛЬТР: Если это сообщение не для текущего открытого чата - В ИГНОР
  //     if (event == 'message.new' || event == 'messages.deleted') {
  //       final int? incomingId = msgData['conversationId'] as int?;
  //       if (_currentConversationId == null ||
  //           incomingId != _currentConversationId) {
  //         log("ℹ️ Ignored message for conversation: $incomingId (current: $_currentConversationId)");
  //         return;
  //       }
  //     }
  //     switch (event) {
  //       case 'message.new':
  //         final newMessage =
  //             ChatMessageDTO.fromJson(msgData as Map<String, dynamic>);
  //         final current = _messagesController.value;
  //         _messagesController.add([newMessage, ...current]);
  //         break;
  //       case 'messages.deleted':
  //         final deletedData = message['data'];
  //         if (deletedData != null) {
  //           final List<int> deletedIds =
  //               List<int>.from(deletedData['messageIds']);

  //           // Получаем текущий список сообщений
  //           final currentMessages = _messagesController.value;

  //           // Фильтруем: оставляем только те, которых НЕТ в списке на удаление
  //           final updatedMessages = currentMessages.where((msg) {
  //             return !deletedIds.contains(msg.id);
  //           }).toList();

  //           // Отправляем обновленный список в поток — UI обновится сам!
  //           _messagesController.add(updatedMessages);
  //           log("✅ Messages removed from stream: $deletedIds");
  //         }

  //         break;

  //       case 'user.status':
  //         _updateStatusFromSocket(msgData);
  //         break;

  //       // case 'joined':
  //       //   // // final joinedConvId = msgData?['conversationId'] as int?;

  //       //   // if (_currentCompanyId != null && _currentToken != null) {
  //       //   //   _loadHistory(_currentCompanyId!, _currentToken!).then((history) {
  //       //   //     _messagesController.add(history);
  //       //   //   }).catchError((e) {
  //       //   //     logger.error('Failed to load history', error: e);
  //       //   //   });
  //       //   // }
  //       //   log("✅ JOINED event received. Loading history for company $_currentCompanyId...");

  //       //   // Важно: Сохраняем ID чата на момент начала загрузки
  //       //   // final loadingChatId = _currentConversationId;

  //       //   if (_currentCompanyId != null && _currentToken != null) {
  //       //     _loadHistory(_currentCompanyId!, _currentToken!).then((history) {
  //       //       // ПРОВЕРКА: Если пока грузилась история, юзер уже нажал "назад"
  //       //       // или перешел в другой чат, не пушим эти сообщения в стрим!
  //       //       if (_currentConversationId == _loadingConversationId) {
  //       //         _messagesController.add(history);
  //       //       } else {
  //       //         log("⚠️ History loaded but user already switched chat. Discarding.");
  //       //       }
  //       //     });
  //       //   }

  //       //   break;

  //       case 'error':
  //         _messagesController
  //             .addError(message['data']?.toString() ?? 'Unknown error');
  //         break;
  //     }
  //   } catch (e) {
  //     logger.error('Error handling WebSocket message', error: e);
  //   }
  // }
  void _handleMessage(dynamic data) {
    try {
      // log("WS RAW DATA: $data"); // Можно раскомментить для отладки

      final message = jsonDecode(data as String);
      final event = message['event'];
      final msgData = message['data'];

      // --- ИСПРАВЛЕННЫЙ ФИЛЬТР ---
      if (event == 'message.new' || event == 'messages.deleted') {
        final int? incomingId = msgData['conversationId'] as int?;

        // 1. Если это НОВОЕ сообщение, ID чата обязан быть и совпадать
        if (event == 'message.new') {
          if (_currentConversationId == null ||
              incomingId != _currentConversationId) {
            // log("ℹ️ Ignored NEW message for conversation: $incomingId");
            return;
          }
        }

        // 2. Если это УДАЛЕНИЕ, ID чата может не прийти (null).
        // Если он пришел - проверяем. Если null - пропускаем (доверяем, что это наши сообщения).
        if (event == 'messages.deleted') {
          if (incomingId != null && incomingId != _currentConversationId) {
            log("ℹ️ Ignored DELETE event for another conversation: $incomingId");
            return;
          }
        }
      }
      // ---------------------------

      switch (event) {
        case 'message.new':
          final newMessage =
              ChatMessageDTO.fromJson(msgData as Map<String, dynamic>);
          final current = _messagesController.value;
          _messagesController.add([newMessage, ...current]);
          break;

        case 'messages.deleted':
          final deletedData = msgData; // msgData уже есть data из json
          if (deletedData != null && deletedData['messageIds'] != null) {
            final List<int> deletedIds =
                List<int>.from(deletedData['messageIds']);

            // Получаем текущий список
            final currentMessages = _messagesController.value;

            // Проверяем, есть ли вообще у нас сообщения с такими ID, чтобы зря не эмитить
            // (Это защита от удаления сообщений из чужих чатов, если id уникальны)
            final bool hasChanges =
                currentMessages.any((msg) => deletedIds.contains(msg.id));

            if (hasChanges) {
              final updatedMessages = currentMessages.where((msg) {
                return !deletedIds.contains(msg.id);
              }).toList();

              _messagesController.add(updatedMessages);
              log("🗑️ [ChatRepo] Удалены сообщения: $deletedIds");
            }
          }
          break;

        case 'user.status':
          _updateStatusFromSocket(msgData);
          break;

        case 'joined':
          // Логика joined (если нужна)
          break;

        case 'error':
          log("❌ WS Error event: ${message['data']}");
          break;
      }
    } catch (e) {
      log("❌ Error handling WebSocket message: $e");
    }
  }

  void _updateStatusFromSocket(dynamic statusData) {
    if (statusData == null) return;
    final int? userId = int.tryParse(statusData['userId'].toString());
    if (userId == null) return;

    _onlineUsersStatusCache[userId] = {
      'userId': userId,
      'isOnline': statusData['isOnline'] == true,
      'lastSeen': statusData['lastSeen']?.toString(),
    };

    // Эмитим копию мапы, чтобы StreamBuilder увидел изменения
    _userStatusController
        .add(Map<int, Map<String, dynamic>>.from(_onlineUsersStatusCache));
  }

  @override
  void leaveChat() {
    _currentConversationId = null;
    _loadingConversationId = null;
    _messagesController.add([]); // Чистим стрим при выходе
    log("Вышли из чата, ID сброшен");
  }

  @override
  Future<void> sendMessage(String content,
      {int? replyToId, int? targetConversationId}) async {
    if (content.trim().isEmpty) return;
    if (_channel == null || _channel!.closeCode != null) {
      print("⚠️ Connection lost. Reconnecting before sending...");
      await ensureConnection(); // Пробуем восстановить связь
    }

    if (_channel == null || _currentConversationId == null) {
      throw Exception('Not connected to any conversation');
    }
    final int finalConversationId =
        targetConversationId ?? _currentConversationId!;
    try {
      _sendJson({
        'event': 'message.send',
        'data': {
          // 'conversationId': _currentConversationId,
          'conversationId': finalConversationId,
          'content': content.trim(),
          if (replyToId != null) 'replyToId': replyToId,
        },
      });
      log('Sending message to Chat #$finalConversationId');
    } catch (e) {
      log("❌ Error sending message. Retrying connection...");
      await ensureConnection();
      _sendJson({
        'event': 'message.send',
        'data': {
          // 'conversationId': _currentConversationId,
          'conversationId': finalConversationId,
          'content': content.trim(),
          if (replyToId != null) 'replyToId': replyToId,
        },
      });
    }
  }

  // Метод для восстановления связи (использует сохраненные token и companyId)
  @override
  Future<void> ensureConnection() async {
    if (_currentCompanyId != null && _currentToken != null) {
      await connectToChat(_currentCompanyId!, _currentToken!);
    }
  }

  void _sendJson(Map<String, dynamic> data) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

// --- PING / PONG (Сердцебиение) ---
  // Каждые 30 секунд шлем пустой пакет, чтобы Nginx/Router не закрывал канал
  void _startPing() {
    _stopPing();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_channel != null) {
        // Отправляем что-то, что сервер просто проигнорирует, но соединение останется активным
        // Если у тебя на бэке нет обработчика 'ping', это нормально, главное что данные прошли
        try {
          _sendJson({'event': 'ping', 'data': {}});
        } catch (_) {}
      }
    });
  }

  void _stopPing() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  @override
  Future<void> disconnect() async {
    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
      _currentConversationId = null;
    }
  }

  @override
  Future<List<ConversationDTO>> findConversationsForUser(String token) async {
    final dynamic response = await _restClient.get(
      'conversations',
      headers: {'Authorization': 'Bearer $token'},
    );

    List<dynamic> rawList = [];
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      rawList = response['data'] as List<dynamic>;
    } else if (response is List) {
      rawList = response;
    }

    final conversations = rawList
        .map((e) {
          if (e is Map<String, dynamic>) {
            try {
              final dto = ConversationDTO.fromJson(e);

              // === ВОТ ТУТ МЫ ИСПОЛЬЗУЕМ ЭТОТ МЕТОД ===
              // Если у чата есть партнер, сохраняем его статус в кэш сразу
              if (dto.partner != null) {
                _updateUserStatusInCache(dto.partner!);
              }
              // =======================================

              return dto;
            } catch (error) {
              print('PARSING ERROR in ConversationDTO: $error');
              return ConversationDTO(id: -1);
            }
          }
          return ConversationDTO(id: -1);
        })
        .where((dto) => dto.id != -1)
        .toList();

    return conversations;
  }

  @override
  void deleteMessages(List<int> ids) {
    if (_currentConversationId == null) return;

    _sendJson({
      'event': 'message.delete', // Должно совпадать с @SubscribeMessage на бэке
      'data': {
        'conversationId': _currentConversationId,
        'messageIds': ids,
      },
    });
  }
}
