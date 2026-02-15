// lib/src/feature/chat/data/chat_repository_impl.dart
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

  ChatRepositoryImpl(this._restClient);

  @override
  Stream<List<ChatMessageDTO>> getMessagesStream(int conversationId) {
    return _messagesController.stream;
  }

  Future<List<ChatMessageDTO>> _loadHistory(int companyId, String token) async {
    try {
      final response = await _restClient.get(
        'conversations/$companyId/messages',
        headers: {'Authorization': 'Bearer $token'},
      );
      final items = (response['items'] as List?) ?? [];
      final list = <ChatMessageDTO>[];
      for (var item in items) {
        try {
          list.add(ChatMessageDTO.fromJson(item as Map<String, dynamic>));
        } catch (e, stack) {
          logger.error('Failed to parse message', error: e, stackTrace: stack);
          // Пропускаем битое сообщение
        }
      }
      return list;
    } catch (e) {
      logger.error('Load history failed', error: e);
      return [];
    }
  }

  @override
  Future<void> connectToChat(int companyId, String token) async {
    _currentToken = token;
    _currentCompanyId = companyId;
    final chatInfo = await _restClient.get(
      'conversations/by-company/$companyId',
      headers: {'Authorization': 'Bearer $token'},
    );
    // Проверьте, что companyId — это число, а не строка
    print('companyId type: ${companyId.runtimeType}'); // должно быть int
    final conversationId = chatInfo['id'] as int;
    _currentConversationId = conversationId;

    final uri = Uri(
      // scheme: kIsWeb ? 'wss' : 'ws',
      scheme: 'wss', // для ngrok
      // host: kIsWeb ? 'localhost' : '10.0.2.2',
      host: '2f9e-94-158-58-248.ngrok-free.app', // для ngrok
      // port: kIsWeb ? 443 : 5000, // для ngrok порт убираем
      path: '/chat',
      queryParameters: {'token': token},
    );

    if (_channel != null) {
      await _channel!.sink.close();
    }

    try {
      _channel = IOWebSocketChannel.connect(
        uri.toString(),
        headers: {
          'ngrok-skip-browser-warning': 'true',
        },
        pingInterval: const Duration(seconds: 5),
      );
      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          logger.error('WebSocket error', error: error);
          _messagesController.addError(error);
          _stopPing();
        },
        onDone: () {
          logger.info('WebSocket connection closed');
          _stopPing();
          _channel = null;
        },
      );

      // Присоединяемся к чату
      _sendJson({
        'event': 'join',
        'data': {'conversationId': conversationId}
      });
      _startPing();
      print("✅ CHAT CONNECTED SUCCESSFULLY");
    } catch (e) {
      logger.error('Failed to connect to chat', error: e);
      _messagesController.addError(e);
    }
  }

  void _handleMessage(dynamic data) {
    try {
      print(
          "WS RAW DATA: $data"); // Логируем всё, чтобы видеть приходят ли ивенты

      final message = jsonDecode(data as String);
      final event = message['event'];

      switch (event) {
        case 'message.new':
          final msgData = message['data'];
          // Важно: проверяем на null
          if (msgData == null) return;
          final sender = UserDTO.fromJson(msgData['sender']);
          final newMessage = ChatMessageDTO(
            id: msgData['id'],
            content: msgData['content'],
            createdAt: DateTime.parse(msgData['createdAt']),
            sender: sender,
            conversationId: msgData['conversationId'],
          );
          final current = _messagesController.value;
          _messagesController.add([newMessage, ...current]);
          break;
        // 👇👇👇 ДОБАВЬ ВОТ ЭТОТ БЛОК 👇👇👇
        case 'user.status':
          print("🔥 WS STATUS EVENT RECEIVED: $message"); // Для отладки
          final statusData = message['data'];
          if (statusData != null) {
            // 1. Приводим типы жестко
            final int userId = int.parse(statusData['userId'].toString());
            final bool isOnline = statusData['isOnline'] == true;
            final String? lastSeen = statusData['lastSeen'];

            // 2. Обновляем локальный кэш
            _onlineUsersStatusCache[userId] = {
              'userId': userId,
              'isOnline': isOnline,
              'lastSeen': lastSeen
            };

            print("✅ UPDATING STREAM FOR USER $userId -> $isOnline");

            // 3. !!! ГЛАВНОЕ ИСПРАВЛЕНИЕ !!!
            // Создаем НОВУЮ Map, иначе StreamBuilder не увидит изменений
            final newMap =
                Map<int, Map<String, dynamic>>.from(_onlineUsersStatusCache);
            _userStatusController.add(newMap);
          }
          break;
        // 👆👆👆 КОНЕЦ БЛОКА 👆👆👆
        case 'joined':
          if (_currentCompanyId != null && _currentToken != null) {
            _loadHistory(_currentCompanyId!, _currentToken!).then((history) {
              _messagesController.add(history);
            }).catchError((e) {
              logger.error('Failed to load history', error: e);
            });
          }
          break;
        case 'error':
          _messagesController
              .addError(message['data']?.toString() ?? 'Unknown error');
          break;
      }
    } catch (e) {
      logger.error('Error handling WebSocket message', error: e);
    }
  }

  @override
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    if (_channel == null || _channel!.closeCode != null) {
      print("⚠️ Connection lost. Reconnecting before sending...");
      await ensureConnection(); // Пробуем восстановить связь
    }

    if (_channel == null || _currentConversationId == null) {
      throw Exception('Not connected to any conversation');
    }
    try {
      _sendJson({
        'event': 'message.send',
        'data': {
          'conversationId': _currentConversationId,
          'content': content.trim()
        },
      });
    } catch (e) {
      print("❌ Error sending message. Retrying connection...");
      await ensureConnection();
      _sendJson({
        'event': 'message.send',
        'data': {
          'conversationId': _currentConversationId,
          'content': content.trim()
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

  // // Опционально: закрыть стрим при уничтожении
  // void dispose() {
  //   _messagesController.close();
  //   disconnect();
  // }

  // @override
  // Future<List<ConversationDTO>> findConversationsForUser(String token) async {
  //   // Мы явно указываем динамический тип для ответа, так как структура может меняться
  //   final dynamic response = await _restClient.get(
  //     'conversations',
  //     headers: {'Authorization': 'Bearer $token'},
  //   );

  //   print('BACKEND RESPONSE: $response');

  //   List<dynamic> rawList;

  //   // 1. Если это Map и содержит ключ 'data' (стандартный оберт NestJS)
  //   if (response is Map && response.containsKey('data')) {
  //     rawList = response['data'] as List<dynamic>;
  //   }
  //   // 2. Если это уже список (прямой ответ .map из NestJS)
  //   else if (response is List) {
  //     rawList = response;
  //   }
  //   // 3. На случай непредвиденной структуры
  //   else {
  //     rawList = [];
  //   }

  //   return rawList
  //       .map((e) => ConversationDTO.fromJson(e as Map<String, dynamic>))
  //       .toList();
  // }
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

    return rawList
        .map((e) {
          if (e is Map<String, dynamic>) {
            try {
              return ConversationDTO.fromJson(e);
            } catch (error) {
              print('PARSING ERROR in ConversationDTO: $error');
              return ConversationDTO(
                id: -1,
              ); // Исправлено: добавили participants
            }
          } else {
            return ConversationDTO(
              id: -1,
            ); // Исправлено: добавили participants
          }
        })
        .where((dto) => dto.id != -1)
        .toList();
  }
}
