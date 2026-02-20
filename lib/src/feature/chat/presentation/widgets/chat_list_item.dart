import 'package:coment_app/src/core/constant/constants.dart';
import 'package:coment_app/src/feature/chat/model/conversation_dto.dart';
import 'package:flutter/material.dart';

class ChatListItem extends StatelessWidget {
  final ConversationDTO conversation;
  final VoidCallback onTap;

  const ChatListItem({
    required this.conversation,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final String nameToDisplay =
        (conversation.title != null && conversation.title!.isNotEmpty)
            ? conversation.title!
            : (conversation.partner?.name ?? 'Неизвестный');
    return ListTile(
      leading: Container(
        height: 90,
        width: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF7573F3), width: 3),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(
              conversation.partner?.avatar != null
                  ? '${conversation.partner?.avatar}'
                  : NOT_FOUND_IMAGE,
            ),
          ),
        ),
      ),
      title: Text(nameToDisplay),
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
        onTap();
      },
    );
  }
}
