import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/auth/models/user_dto.dart';
import 'package:coment_app/src/feature/chat/bloc/chat_cubit.dart';
import 'package:coment_app/src/feature/chat/model/chat_message_dto.dart';
import 'package:coment_app/src/feature/chat/presentation/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatusUserWidget extends StatefulWidget implements PreferredSizeWidget {
  const StatusUserWidget({
    super.key,
    required this.widget,
    required this.currentUser,
    required this.isChatPageActive,
    // required this.conversation,
  });

  final ChatPage widget;
  final UserDTO currentUser;
  final bool isChatPageActive;
// final ConversationDTO conversation;
  @override
  State<StatusUserWidget> createState() => _StatusUserWidgetState();

  @override
  Size get preferredSize =>
      Size(double.infinity, isChatPageActive ? 150 : kToolbarHeight);
}

class _StatusUserWidgetState extends State<StatusUserWidget> {
  String _formatDate(DateTime? time) {
    if (time == null) return 'недавно';

    final localTime = time.toLocal();
    final now = DateTime.now();
    final diff = now.difference(localTime);

    // 1. Меньше минуты
    if (diff.inMinutes < 1) return 'только что';

    // 2. Меньше часа
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин. назад';

    // 3. Сегодня (в пределах календарного дня)
    if (localTime.day == now.day &&
        localTime.month == now.month &&
        localTime.year == now.year) {
      return 'сегодня в ${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
    }

    // 4. Вчера
    final yesterday = now.subtract(const Duration(days: 1));
    if (localTime.day == yesterday.day &&
        localTime.month == yesterday.month &&
        localTime.year == yesterday.year) {
      return 'вчера в ${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
    }

    // 5. Давно (добавляем год, если это не текущий год)
    String month = localTime.month.toString().padLeft(2, '0');
    String day = localTime.day.toString().padLeft(2, '0');

    if (localTime.year != now.year) {
      return '$day.$month.${localTime.year}';
    }

    // Если текущий год, можно вернуть "день.месяц в часы:минуты"
    return '$day.$month в ${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // 1. Используем watch, чтобы виджет обновлялся при загрузке сообщений
    final chatCubit = context.watch<ChatCubit>();
    final activeRepo = chatCubit.repository;

    // 2. Достаем сообщения из стейта (учитываем 3 аргумента в loaded)
    final messages = chatCubit.state.maybeWhen(
      loaded: (msgs, _, __, ___) => msgs,
      orElse: () => <ChatMessageDTO>[],
    );

    // 3. Пытаемся найти "свежего" пользователя в сообщениях
    UserDTO? senderFromMessages;
    if (messages.isNotEmpty) {
      for (var msg in messages) {
        if (msg.sender.id != widget.currentUser.id) {
          senderFromMessages = msg.sender;
          break; // Нашли первого встречного собеседника и выходим
        }
      }
    }

    // 4. Итоговый объект пользователя для отображения:
    // Если в сообщениях нашли — берем его (там есть username и флаг),
    // если нет — берем старый из параметров виджета.
    final userToDisplay = senderFromMessages ?? widget.widget.targetUser;

    // Если совсем никого нет (групповой чат без данных)
    // ignore: unnecessary_null_comparison
    if (userToDisplay == null) {
      return CustomAppBar(
        title: widget.widget.companyName,
        subTitle: '...',
        isChatPageActive: true,
      );
    }

    final int targetId = int.tryParse(userToDisplay.id.toString()) ?? 0;

    // ТОЛЬКО STREAM BUILDER
    return StreamBuilder<Map<int, Map<String, dynamic>>>(
      stream: activeRepo.userStatusStream,
      initialData: activeRepo.currentStatusCache,
      builder: (context, snapshot) {
        final allStatuses = snapshot.data ?? {};
        final userStatusFromWs = allStatuses[targetId];

        bool isOnline;
        DateTime? lastSeenDate;

        if (userStatusFromWs != null) {
          // Если пришел ивент по сокету
          isOnline = userStatusFromWs['isOnline'] == true;
          if (userStatusFromWs['lastSeen'] != null) {
            lastSeenDate =
                DateTime.tryParse(userStatusFromWs['lastSeen'].toString());
          }
        } else {
          // Фолбэк на исторические данные из профиля
          // isOnline = targetUser.isOnline;
          // lastSeenDate = targetUser.lastSeen;
          isOnline = userToDisplay.isOnline;
          lastSeenDate = userToDisplay.lastSeen;
        }

        return CustomAppBar(
          isOnline: isOnline,
          // title: targetUser.name ?? widget.widget.companyName,
          title:
              // userToDisplay.showRealName == true
              //     ? '@${userToDisplay.username}'
              //     :
              //     userToDisplay.displayName,
              userToDisplay.showRealName == true &&
                      (userToDisplay.username?.isNotEmpty ?? false)
                  ? '@${userToDisplay.username}'
                  : (userToDisplay.name?.isNotEmpty ?? false)
                      ? userToDisplay.name!
                      : widget.widget.companyName,
          companyName: widget.widget.companyName,
          companyStyle: AppTextStyles.fs12w400,
          subTitle: isOnline ? 'В сети' : 'Был(а) ${_formatDate(lastSeenDate)}',
          textStyle: AppTextStyles.fs18w700,
          subTitleStyle: AppTextStyles.fs12w400.copyWith(
            color: isOnline ? AppColors.green : AppColors.greyTextColor,
          ),
          isChatPageActive: widget.isChatPageActive,
          actions: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.settings,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
