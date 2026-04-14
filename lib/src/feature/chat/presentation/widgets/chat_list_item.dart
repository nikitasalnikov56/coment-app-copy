import 'dart:developer';
import 'package:coment_app/src/core/constant/constants.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/feature/chat/model/conversation_dto.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

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
    log("🟠 [ChatListItem] Отрисовка чата ${conversation.id}. unreadCount = ${conversation.unreadCount}");
    final partner = conversation.partner;

    // Логика выбора имени:
    // 1. Если showRealName == true, берем ник (username)
    // 2. Если данных нет или флаг false, берем обычное имя
    // 3. Если и его нет, берем заголовок диалога
    String nameToDisplay;
    String? companyNameToDisplay = conversation.companyName;

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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFF5F5F5),
          boxShadow: const [
            BoxShadow(
              color: AppColors.barrierColor,
              offset: Offset(
                1,
                2,
              ),
              blurRadius: 4,
            ),
          ]),
      child: ListTile(
        titleAlignment: ListTileTitleAlignment.center,
        isThreeLine: true,
        leading: Container(
          height: 90,
          width: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF7573F3), width: 3),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: conversation.partner?.avatar != null
                  ? NetworkImage(
                      '${conversation.partner?.avatar}',
                    )
                  : const AssetImage(NO_IMAGE),
            ),
          ),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              partner?.showRealName == true ? '@$nameToDisplay' : nameToDisplay,
              style: AppTextStyles.fs16w400.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            if (companyNameToDisplay != null &&
                companyNameToDisplay.isNotEmpty &&
                companyNameToDisplay != 'null')
              Text(
                companyNameToDisplay,
                style: AppTextStyles.fs12w400,
              ),
            companyNameToDisplay == null || companyNameToDisplay.isEmpty
                ? const Gap(0)
                : const Gap(10)
          ],
        ),
        subtitle: Text(
          subtitleText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.fs12w400.copyWith(
            color: subtitleText == '🎙 Голосовое сообщение'
                ? AppColors.mainColor
                : AppColors.greyTextColor2,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        trailing: Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (conversation.unreadCount > 0)
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${conversation.unreadCount}',
                      style: AppTextStyles.fs12w400.copyWith(
                        color: AppColors.backgroundColor2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(
                  height: 12,
                ),
              if (lastMsg?.createdAt != null)
                Text(
                  '${lastMsg!.createdAt.hour}:${lastMsg.createdAt.minute.toString().padLeft(2, '0')}',
                  style: AppTextStyles.fs12w400.copyWith(
                    color: Theme.of(context).textTheme.titleSmall?.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        onTap: () {
          onTap();
        },
      ),
    );
  }
}
