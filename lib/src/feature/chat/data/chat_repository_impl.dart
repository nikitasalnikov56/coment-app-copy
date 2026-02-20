// lib/src/feature/chat/data/chat_repository_impl.dart
import 'dart:developer';

import 'package:coment_app/src/core/rest_client/rest_client.dart';
import 'package:coment_app/src/feature/auth/models/user_dto.dart';
import 'package:coment_app/src/feature/chat/data/chat_repository.dart';
import 'dart:async';
import 'dart:convert';
// import 'package:coment_app/src/core/utils/refined_logger.dart';
import 'package:coment_app/src/feature/chat/model/chat_message_dto.dart';
import 'package:coment_app/src/feature/chat/model/conversation_dto.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatRepositoryImpl implements IChatRepository {
  final IRestClient _restClient;
  String? _currentToken;
  int? _currentConversationId;
  int? _currentUserId;
  bool _isReconnecting = false;

  // Состояние соединения
  WebSocketChannel? _channel;
  Timer? _pingTimer;

  final BehaviorSubject<List<ChatMessageDTO>> _messagesController =
      BehaviorSubject.seeded([]);

// 1. КЭШ СОСТОЯНИЙ: Ключ = ID юзера (int), Значение = Данные статуса
  final Map<int, Map<String, dynamic>> _onlineUsersStatusCache = {};
  @override
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
  @override
  List<ChatMessageDTO> get currentMessages => _messagesController.value;
  int? loadingConversationId;

  // 1. Добавляем контроллер для уведомления об обновлении списка бесед
  final PublishSubject<void> _conversationsUpdateController =
      PublishSubject<void>();

// 2. Добавляем геттер для этого стрима
  @override
  Stream<void> get conversationsUpdateStream =>
      _conversationsUpdateController.stream;

  ChatRepositoryImpl(this._restClient);

  @override
  Stream<List<ChatMessageDTO>> getMessagesStream(int conversationId) {
    return _messagesController.stream;
  }

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

    _channel!.stream.listen(_handleMessage, onError: (e) {
      log("❌ WS Error: $e");
      scheduleReconnect();
    }, onDone: () {
      log("ℹ️ WS Connection Closed");
      scheduleReconnect();
    });
  }

  void _handleMessage(dynamic data) {
    try {
      // log("WS RAW DATA: $data"); // Можно раскомментить для отладки

      final message = jsonDecode(data as String);
      final event = message['event'];
      final msgData = message['data'];

      log("📥 WS EVENT: $event | DATA: $msgData");

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
          _conversationsUpdateController.add(null);
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
        case 'users.online_list':
          final List<dynamic> onlineIds = msgData['onlineIds'] ?? [];
          log("🌐 Получен список пользователей онлайн: $onlineIds");

          for (var id in onlineIds) {
            final int? userId = int.tryParse(id.toString());
            if (userId != null) {
              _onlineUsersStatusCache[userId] = {
                'userId': userId,
                'isOnline': true,
                'lastSeen': DateTime.now()
                    .toIso8601String(), // Раз он в списке, значит онлайн сейчас
              };
            }
          }
          // Уведомляем UI о массовом обновлении статусов
          _userStatusController.add(
              Map<int, Map<String, dynamic>>.from(_onlineUsersStatusCache));
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

    // Проверяем типы данных!
    final rawId = statusData['userId'];
    final int? userId = rawId is int ? rawId : int.tryParse(rawId.toString());

    if (userId == null) {
      log("⚠️ [ChatRepo] Не удалось распарсить userId: $rawId");
      return;
    }

    _onlineUsersStatusCache[userId] = {
      'userId': userId,
      'isOnline': statusData['isOnline'] == true,
      'lastSeen': statusData['lastSeen']?.toString(),
    };

    log("✅ Статус юзера $userId обновлен: ${statusData['isOnline']}");

    // ВАЖНО: создаем НОВУЮ мапу, чтобы StreamBuilder "проснулся"
    _userStatusController
        .add(Map<int, Map<String, dynamic>>.from(_onlineUsersStatusCache));
  }

  @override
  void leaveChat() {
    _currentConversationId = null;
    loadingConversationId = null;
    _messagesController.add([]); // Чистим стрим при выходе
    // ВАЖНО: Закрываем сокет, чтобы бэк получил disconnect
    disconnect();
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
    if ((_channel == null || _channel!.closeCode != null) &&
        _currentConversationId != null &&
        _currentToken != null) {
      // await connectToChat(_currentCompanyId!, _currentToken!);
      await _establishSocketConnection(_currentToken!);
      // После коннекта ОБЯЗАТЕЛЬНО переподписываемся на комнату
      _sendJson({
        'event': 'join',
        'data': {'conversationId': _currentConversationId}
      });

      _startPing();
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

  @override
  void scheduleReconnect() {
    _stopPing();

    // Если пользователь ВЫШЕЛ из чата (_currentConversationId == null),
    // мы НЕ будем пытаться переподключиться. Экономим батарею и ресурсы.
    if (_isReconnecting || _currentConversationId == null) return;
    _isReconnecting = true;
    Timer(const Duration(seconds: 3), () async {
      // Если пока ждали таймер, пользователь закрыл чат — отменяем
      if (_currentConversationId == null) {
        _isReconnecting = false;
        log("🔄 [ChatRepo] Фоновое переподключение...");
        // ensureConnection();
        return;
      }
      try {
        await ensureConnection();
        log("✅ [ChatRepo] Reconnected successfully");
      } catch (e) {
        log("❌ [ChatRepo] Reconnect failed, trying again...");
      } finally {
        _isReconnecting = false;
      }
    });
  }
}
