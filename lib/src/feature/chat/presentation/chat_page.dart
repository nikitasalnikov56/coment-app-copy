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
import 'package:coment_app/src/feature/chat/ui/widgets/date_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

@RoutePage()
class ChatPage extends StatefulWidget implements AutoRouteWrapper {
  const ChatPage({
    super.key,
    required this.companyId,
    required this.companyName,
    required this.currentUser,
    required this.accessToken,
  });

  final int companyId;
  final String companyName;
  final String accessToken;
  final UserDTO currentUser;

  @override
  State<ChatPage> createState() => _ChatPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(
        context.repository.chatRepository,
        companyId,
        accessToken,
      ),
      child: this,
    );
  }
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
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
        return Scaffold(
          appBar: StatusUserWidget(
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
              _buildInputArea(),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessageDTO message, bool isOwnMessage) {
    return Padding(
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
              child: Text(
                message.content,
                style: AppTextStyles.fs14w400.copyWith(
                  color: isOwnMessage ? Colors.white : AppColors.text,
                ),
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
                      backgroundImage: NetworkImage(widget.currentUser.avatar!),
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
    );
  }

  Widget _buildInputArea() {
    return Container(
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const Gap(8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.mainColor,
              borderRadius: BorderRadius.circular(50)
            ),
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
    );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatCubit>().sendMessage(text);
    _textController.clear();
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
    // 1. БЕРЕМ КУБИТ
    final chatCubit = context.read<ChatCubit>();

    // 2. БЕРЕМ РЕПОЗИТОРИЙ ИЗ КУБИТА (Тот самый, где живет активный Сокет!)
    final activeRepo = chatCubit.repository;

    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        UserDTO? targetUser;
        final messages = chatCubit.currentMessages;

        if (messages.isNotEmpty) {
          try {
            targetUser = messages
                .firstWhere((m) => m.sender.id != widget.currentUser.id)
                .sender;
          } catch (_) {}
        }

        if (targetUser == null) {
          return CustomAppBar(
            title: widget.widget.companyName,
            subTitle: '...',
          );
        }

        final nonNullTargetUser = targetUser;
        final int targetId = int.tryParse(nonNullTargetUser.id.toString()) ?? 0;

        // 3. СЛУШАЕМ СТРИМ АКТИВНОГО РЕПОЗИТОРИЯ
        return StreamBuilder<Map<int, Map<String, dynamic>>>(
          stream: activeRepo.userStatusStream,
          // Используем кэш для мгновенного отображения при перерисовке
          initialData: activeRepo.currentStatusCache,
          builder: (context, snapshot) {
            final allStatuses = snapshot.data ?? {};

            // ПРИНТ ДЛЯ ПРОВЕРКИ (Увидишь в консоли при смене статуса)
            if (snapshot.hasData) {
              log(
                  "UI STREAM UPDATE: Keys available: ${allStatuses.keys.toList()} looking for $targetId");
            }

            final userStatusFromWs = allStatuses[targetId];
            bool isOnline;
            DateTime? lastSeenDate;

            if (userStatusFromWs != null) {
              // Данные из сокета
              isOnline = userStatusFromWs['isOnline'] == true;
              if (userStatusFromWs['lastSeen'] != null) {
                lastSeenDate =
                    DateTime.tryParse(userStatusFromWs['lastSeen'].toString());
              }
            } else {
              // Данные из истории (по умолчанию)
              isOnline = nonNullTargetUser.isOnline;
              lastSeenDate = nonNullTargetUser.lastSeen;
            }

            return CustomAppBar(
              isOnline: isOnline,
              title: nonNullTargetUser.name ?? widget.widget.companyName,
              subTitle:
                  isOnline ? 'В сети' : 'Был(а) ${_formatDate(lastSeenDate)}',
                  textStyle: AppTextStyles.fs18w700 ,
                  subTitleStyle:  AppTextStyles.fs12w400.copyWith(
                        color: isOnline
                            ? AppColors.green
                            : AppColors.greyTextColor,
                      ),
            );
          },
        );
      },
    );
  }
}
