// lib/src/feature/chat/presentation/widgets/chat_list_item.dart
import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
// import 'package:coment_app/src/feature/auth/models/user_dto.dart';
import 'package:coment_app/src/feature/chat/model/conversation_dto.dart';
import 'package:flutter/material.dart';

class ChatListItem extends StatelessWidget {
  final ConversationDTO conversation;
  // final VoidCallback onTap;

  const ChatListItem({
    required this.conversation,
    // required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Берём НЕ текущего пользователя, а другого участника
    final currentUser = context.repository.authRepository.user!;
    final displayName = conversation.title!.isNotEmpty
        ? conversation.title
        : (conversation.partner?.name ?? 'Неизвестный');
    // Определяем название чата
    String chatTitle;
    if (currentUser.role == 'owner') {
      // Владелец видит имя пользователя
      chatTitle = displayName ?? 'Пользователь';
    } else {
      // Пытаемся достать ID из заголовка или используем имя
      final companyIdFromTitle = _extractCompanyId(conversation.title);
      chatTitle = companyIdFromTitle != null
          ? 'Компания #$companyIdFromTitle'
          : (displayName ?? 'Чат');
    }

    return ListTile(
      leading: CircleAvatar(
        child: Text(
          (displayName != null && displayName.isNotEmpty)
              ? displayName[0].toUpperCase()
              : '?',
        ),
      ),
      title: Text(displayName ?? 'Чат'),
      subtitle: Text(
        conversation.lastMessage?.content ?? 'Нет сообщений',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: conversation.lastMessage?.createdAt != null
          ? Text(
              '${conversation.lastMessage!.createdAt.hour}:${conversation.lastMessage!.createdAt.minute}')
          : null,
      onTap: () {
       // 1. Пытаемся взять ID напрямую из нового поля в DTO
        // 2. Если его там нет (для старых записей), пытаемся вытащить из заголовка
        final companyId = conversation.companyId ?? _extractCompanyId(conversation.title);
        
        if (companyId == null) {
          // Если мы здесь, значит это личный чат без привязки к компании
          // Можно либо выдать ошибку, либо реализовать переход в ChatRoute по другому параметру
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка: ID компании не найден')),
          );
          return;
        }

        context.router.push(
          ChatRoute(
            conversationId: conversation.id,
            companyName: chatTitle,
            currentUser: currentUser,
            accessToken: currentUser.accessToken!,
          ),
        );
       
      },
    );
  }

  int? _extractCompanyId(String? title) {
    final match = RegExp(r'company-(\d+)').firstMatch(title ?? '');
    return match != null ? int.parse(match.group(1)!) : null;
  }
}
