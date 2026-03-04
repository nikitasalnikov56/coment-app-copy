import 'package:coment_app/src/core/constant/constants.dart';
import 'package:coment_app/src/core/theme/resources.dart';
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
    // final String nameToDisplay =
    //     (conversation.title != null && conversation.title!.isNotEmpty)
    //         ? conversation.title!
    //         : (conversation.partner?.name ?? 'Неизвестный');
    final partner = conversation.partner;

    // Логика выбора имени:
    // 1. Если showRealName == true, берем ник (username)
    // 2. Если данных нет или флаг false, берем обычное имя
    // 3. Если и его нет, берем заголовок диалога
    String nameToDisplay;

    if (partner?.showRealName == true) {
      nameToDisplay = partner?.username ?? partner?.displayName ?? 'Скрыто';
    } else {
      nameToDisplay =
          (conversation.title != null && conversation.title!.isNotEmpty)
              ? conversation.title!
              : (partner?.name ?? 'Неизвестный');
    }

// 2. Логика для отображения текста последнего сообщения
    String subtitleText = 'Нет сообщений';
    final lastMsg = conversation.lastMessage;

print(lastMsg?.attachments);
    if (lastMsg != null) {
      // Проверяем, есть ли ссылка на голосовое
      if (lastMsg.voiceUrl != null && lastMsg.voiceUrl!.isNotEmpty) {
        subtitleText =
            '🎙 Голосовое сообщение'; // Иконка микрофона для наглядности
      } else if (lastMsg.attachments != null &&
          lastMsg.attachments!.isNotEmpty) {
        subtitleText = '📎 Файл';
      } else if (lastMsg.content.isNotEmpty) {
        subtitleText = lastMsg.content;
      }
    }

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
      title: Text(
        partner?.showRealName == true ? '@$nameToDisplay' : nameToDisplay,
        style: AppTextStyles.fs16w400.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
      subtitle: Text(
        // conversation.lastMessage?.content ?? 'Нет сообщений',
        subtitleText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.fs12w400.copyWith(
            color: subtitleText == '🎙 Голосовое сообщение'
                ? AppColors.mainColor
                : AppColors.greyTextColor2,
            fontWeight: FontWeight.w600),
      ),
      trailing: lastMsg?.createdAt != null
          ? Text(
              '${lastMsg!.createdAt.hour}:${lastMsg.createdAt.minute.toString().padLeft(2, '0')}',
              style: AppTextStyles.fs12w400
                  .copyWith(color: AppColors.greyTextColor),
            )
          : null,
      onTap: () {
        onTap();
      },
    );
  }
}
