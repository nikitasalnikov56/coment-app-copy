// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/presentation/widgets/dialog/toaster.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/auth/models/user_dto.dart';
import 'package:coment_app/src/feature/chat/bloc/chat_cubit.dart';
import 'package:coment_app/src/feature/chat/model/chat_message_dto.dart';
import 'package:coment_app/src/feature/chat/model/conversation_dto.dart';
import 'package:coment_app/src/feature/chat/ui/widgets/date_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class ChatPage extends StatefulWidget implements AutoRouteWrapper {
  const ChatPage({
    super.key,
    required this.conversationId,
    // required this.companyId,
    required this.companyName,
    required this.currentUser,
    required this.accessToken,
    required this.targetUser,
    
  });
  final int conversationId;
  // final int companyId;
  final String companyName;
  final String accessToken;
  final UserDTO currentUser;
  final UserDTO targetUser;

  @override
  State<ChatPage> createState() => _ChatPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(
        context.repository.chatRepository,
        // companyId,
        conversationId,
        accessToken,
      ),
      child: this,
    );
  }
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatCubit _cubit;

  @override
  void initState() {
    _cubit = context.read<ChatCubit>();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    _cubit.close();
    WidgetsBinding.instance.removeObserver(this);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

// 4. Слушаем, когда приложение "просыпается"
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      log("📱 APP RESUMED: Reconnecting socket...");
      // Дергаем репозиторий, чтобы он проверил связь
      // Так как репозиторий в кубите, можно сделать так:
      final cubit = context.read<ChatCubit>();
      // Если у репозитория есть метод connect(), вызови его.
      // Если он приватный, можно просто вызвать какой-то метод кубита, который инициирует проверку.
      // Но самый простой способ, если ты сделал Шаг 1 (enableReconnection) - библиотека сама попробует.
      // Для надежности можно сделать публичный метод reconnect() в кубите:
      cubit.checkConnection(); // <-- Реализуй этот метод в Cubit (см. ниже)
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          error: (message) {
            Toaster.showErrorTopShortToast(context, message);
          },
        );
      },
      builder: (context, state) {
        final cubit = context.read<ChatCubit>();
        final isSelectionMode = cubit.selectedIds.isNotEmpty;
        return Scaffold(
          appBar: isSelectionMode
              ? AppBar(
                  leading: IconButton(
                    onPressed: cubit.clearSelection,
                    icon: const Icon(
                      Icons.close,
                    ),
                  ),
                  title: Text('${cubit.selectedIds.length}'),
                  actions: [
                    IconButton(
                      onPressed: () async {
                        final selectedMsgs = cubit.currentMessages
                            .where((m) => cubit.selectedIds.contains(m.id))
                            .map((m) => m.content)
                            .join('\n');
                        await Clipboard.setData(
                            ClipboardData(text: selectedMsgs));
                        cubit.clearSelection();
                        Toaster.showTopShortToast(context,
                            message: 'Скопировано');
                      },
                      icon: const Icon(Icons.copy),
                    ),
                    IconButton(
                      onPressed: () {
                        cubit.deleteSelectedMessages();
                      },
                      icon: const Icon(Icons.delete_outline),
                    )
                  ],
                )
              : StatusUserWidget(
                  widget: widget,
                  currentUser: widget.currentUser,
                ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<ChatMessageDTO>>(
                  stream: context.read<ChatCubit>().messagesStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          context.localized.noMessagesYet,
                          style: AppTextStyles.fs16w400,
                        ),
                      );
                    }

                    final messages = snapshot.data!;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          _scrollController.position.minScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isOwnMessage =
                            message.sender.id == widget.currentUser.id;
                        bool showDateHeader = false;
                        final currentMsgDate = message.createdAt.toLocal();
                        if (index == messages.length - 1) {
                          showDateHeader = true;
                        } else {
                          final nextMessage = messages[index + 1];

                          final prevMsgDate = nextMessage.createdAt.toLocal();

                          if (!isSameDay(currentMsgDate, prevMsgDate)) {
                            showDateHeader = true;
                          }
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (showDateHeader) DateChip(date: currentMsgDate),
                            _buildMessageBubble(message, isOwnMessage),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  // Красивая анимация выезда снизу + прозрачность
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        axisAlignment: -1.0, // Выезжает снизу
                        child: child,
                      ),
                    );
                  },
                  // ЕСЛИ ВЫДЕЛЕНО -> ПОКАЗЫВАЕМ МЕНЮ, ИНАЧЕ -> ПОЛЕ ВВОДА
                  child: isSelectionMode
                      ? _buildSelectionMenu(cubit, context)
                      : _buildInputArea(cubit),
                ),
              ),
              // _buildInputArea(cubit),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectionMenu(ChatCubit cubit, BuildContext context) {
    return Container(
      key: const ValueKey('selectionMenu'), // <--- ВАЖНО ДЛЯ АНИМАЦИИ
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround, // Равномерно распределяем
        children: [
          // Кнопка ОТВЕТИТЬ (показываем только если выбрано 1 сообщение)
          if (cubit.selectedIds.length == 1)
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                  backgroundColor: AppColors.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: () {
                  final msgId = cubit.selectedIds.first;
                  final msg =
                      cubit.currentMessages.firstWhere((e) => e.id == msgId);
                  cubit.setReplyMessage(msg);
                },
                child: Text("Ответить",
                    style: AppTextStyles.fs14w500
                        .copyWith(color: AppColors.greyTextColor2)
                    // TextStyle(color: AppColors.greyTextColor2),
                    ),
              ),
            ),
          const SizedBox(width: 18),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundColor,
                padding: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onPressed: () => _showForwardSheet(context, cubit),
              child: Text(
                'Переслать',
                style: AppTextStyles.fs14w500
                    .copyWith(color: AppColors.greyTextColor2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageDTO message, bool isOwnMessage) {
    // 1. Получаем доступ к кубиту и состоянию
    final cubit = context.read<ChatCubit>();
    final isSelected = cubit.selectedIds.contains(message.id);
    final isSelectionMode = cubit.selectedIds.isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: () {
        cubit.toggleSelection(message.id);
        HapticFeedback.mediumImpact();
      },
      onTap: () {
        if (isSelectionMode) {
          cubit.toggleSelection(message.id);
        }
      },
      child: Container(
        color: isSelected
            ? AppColors.mainColor.withValues(alpha: 0.1)
            : Colors.transparent,
        child: Padding(
          padding: EdgeInsets.only(
            left: isOwnMessage ? 60 : 16,
            right: isOwnMessage ? 16 : 60,
            top: 8,
            bottom: 8,
          ),
          child: Row(
            mainAxisAlignment:
                isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelectionMode ? 32 : 0,
                curve: Curves.easeInOut,
                child: isSelectionMode
                    ? Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: isSelected
                                  ? AppColors.mainColor
                                  : AppColors.grey969696,
                              width: 2),
                          color: isSelected
                              ? AppColors.mainColor
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      )
                    : null,
              ),
              if (!isOwnMessage)
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.grey,
                  ),
                  child: message.sender.avatar != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(message.sender.avatar!),
                          radius: 16,
                        )
                      : const Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.white,
                        ),
                ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  margin: EdgeInsets.only(
                    left: !isOwnMessage ? 8 : 0,
                    right: isOwnMessage ? 8 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: isOwnMessage
                        ? AppColors.mainColor
                        : AppColors.backgroundInputGrey,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.replyTo != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding:
                              const EdgeInsets.only(left: 8, top: 2, bottom: 2),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: isOwnMessage
                                    ? Colors.white70
                                    : AppColors.mainColor,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.replyTo!.sender.name ?? 'User',
                                style: AppTextStyles.fs12w700.copyWith(
                                  color: isOwnMessage
                                      ? Colors.white
                                      : AppColors.mainColor,
                                ),
                              ),
                              Text(
                                message.replyTo!.content,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.fs12w400.copyWith(
                                  color: isOwnMessage
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              )
                            ],
                          ),
                        ),
                      Text(
                        message.content,
                        style: AppTextStyles.fs14w400.copyWith(
                          color: isOwnMessage ? Colors.white : AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isOwnMessage)
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.mainColor,
                  ),
                  child: widget.currentUser.avatar != null
                      ? CircleAvatar(
                          backgroundImage:
                              NetworkImage(widget.currentUser.avatar!),
                          radius: 16,
                        )
                      : const Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.white,
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(ChatCubit cubit) {
    return Container(
      key: const ValueKey('inputArea'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (cubit.replyMessage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.reply,
                    color: AppColors.mainColor,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ответ пользователю ${cubit.replyMessage!.sender.name}',
                          style: AppTextStyles.fs12w500.copyWith(
                            color: AppColors.mainColor,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          cubit.replyMessage!.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.fs12w500.copyWith(
                            fontSize: 13,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      cubit.cancelReply();
                    },
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: context.localized.writeAComment,
                      hintStyle: AppTextStyles.fs14w400.copyWith(
                        color: AppColors.greyTextColor,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundInputGrey,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    textInputAction: TextInputAction.send,
                    onTap: () => context.repository.chatRepository.ensureConnection(),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const Gap(8),
                DecoratedBox(
                  decoration: BoxDecoration(
                      color: AppColors.mainColor,
                      borderRadius: BorderRadius.circular(50)),
                  child: IconButton(
                    onPressed: _sendMessage,
                    padding: const EdgeInsets.only(left: 3, bottom: 3),
                    icon: Image.asset(
                      AssetsConstants.sendMessage,
                      fit: BoxFit.cover,
                      width: 25,
                      height: 25,
                      color: AppColors.btnGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatCubit>().sendMessage(text);
    // final newMessage = 
    ChatMessageDTO(
      id: 0,
      content: text,
      createdAt: DateTime.now(),
      sender: widget.currentUser,
      conversationId: widget.conversationId,
    );

    // context.read<ConversationsCubit>().updateConversationLastMessage(
    //       conversationId: widget.conversationId,
    //       message: newMessage,
    //     );

    _textController.clear();
  }

  void _showForwardSheet(BuildContext context, ChatCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Переслать в...',
                          style: AppTextStyles.fs16w700.copyWith(
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                  ),
                  // список чатов
                  Expanded(
                    child: FutureBuilder<List<ConversationDTO>>(
                      // Используем метод из вашего репозитория
                      future: cubit.repository
                          .findConversationsForUser(widget.accessToken),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child:
                                  Text("Ошибка загрузки: ${snapshot.error}"));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text("Нет доступных чатов"));
                        }
                        final conversations = snapshot.data!;
                        return Flexible(
                          child: ListView.separated(
                            controller: scrollController,
                            itemCount: conversations.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final chat = conversations[index];

                              if (chat.id == cubit.conversationId) {
                                return const SizedBox.shrink();
                              }
                              final userData = chat.partner;
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.mainColor
                                      .withValues(alpha: 0.1),
                                  backgroundImage: userData?.avatar != null
                                      ? NetworkImage("${userData?.avatar}")
                                      : null,
                                  child: userData?.avatar == null
                                      ? const Icon(
                                          Icons.person,
                                          color: AppColors.mainColor,
                                        )
                                      : null,
                                ),
                                title: Text(
                                  "${chat.partner?.name}",
                                  style: AppTextStyles.fs14w500,
                                ),
                                subtitle: Text(
                                  userData?.isOnline == true
                                      ? 'В сети'
                                      : 'Офлайн',
                                  style: TextStyle(
                                    color: userData?.isOnline == true
                                        ? AppColors.green
                                        : Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                onTap: () async {
                                  // // Тут логика: либо отправляем через текущий кубит,
                                  // // либо (что правильнее) вызываем метод репозитория напрямую
                                  // final selectedContent = cubit.currentMessages
                                  //     .where((m) =>
                                  //         cubit.selectedIds.contains(m.id))
                                  //     .map((m) => m.content)
                                  //     .join('\n');

                                  // Закрываем шторку
                                  Navigator.pop(context);

                                  // Показываем лоадер или тост
                                  Toaster.showTopShortToast(context,
                                      message: 'Пересылаем...');

                                  // Отправка (упрощенно)
                                  await cubit.forwardSelectedMessages(chat.id);

                                  // cubit.clearSelection();
                                  if (mounted) {
                                    Toaster.showTopShortToast(context,
                                        message: 'Отправлено');
                                  }
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            });
      },
    );
  }
}

class StatusUserWidget extends StatefulWidget implements PreferredSizeWidget {
  const StatusUserWidget({
    super.key,
    required this.widget,
    required this.currentUser,
  });

  final ChatPage widget;
  final UserDTO currentUser;

  @override
  State<StatusUserWidget> createState() => _StatusUserWidgetState();

  @override
  Size get preferredSize => const Size(double.infinity, kToolbarHeight);
}


class _StatusUserWidgetState extends State<StatusUserWidget> {
  // Форматирование даты
  String _formatDate(DateTime? time) {
    if (time == null) return 'недавно';
    final localTime = time.toLocal();
    final now = DateTime.now();
    final diff = now.difference(localTime);

    if (diff.inMinutes < 1) return 'только что';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин. назад';
    if (diff.inHours < 24) {
      return 'сегодня в ${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
    }
    return '${localTime.day}.${localTime.month}';
  }

  @override
  Widget build(BuildContext context) {
    final chatCubit = context.read<ChatCubit>();
    final activeRepo = chatCubit.repository;
    
    // БЕРЕМ СОБЕСЕДНИКА ИЗ ПАРАМЕТРОВ ВИДЖЕТА!
    final targetUser = widget.widget.targetUser;

    // Если собеседника нет (групповой чат или баг), просто выводим название
    // ignore: unnecessary_null_comparison
    if (targetUser == null) {
      return CustomAppBar(
        title: widget.widget.companyName,
        subTitle: '...',
      );
    }

    final int targetId = int.tryParse(targetUser.id.toString()) ?? 0;

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
            lastSeenDate = DateTime.tryParse(userStatusFromWs['lastSeen'].toString());
          }
        } else {
          // Фолбэк на исторические данные из профиля
          isOnline = targetUser.isOnline;
          lastSeenDate = targetUser.lastSeen;
        }

        return CustomAppBar(
          isOnline: isOnline,
          title: targetUser.name ?? widget.widget.companyName,
          subTitle: isOnline ? 'В сети' : 'Был(а) ${_formatDate(lastSeenDate)}',
          textStyle: AppTextStyles.fs18w700,
          subTitleStyle: AppTextStyles.fs12w400.copyWith(
            color: isOnline ? AppColors.green : AppColors.greyTextColor,
          ),
        );
      },
    );
  }
}