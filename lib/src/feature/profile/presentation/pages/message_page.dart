import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/presentation/widgets/dialog/toaster.dart';
import 'package:coment_app/src/core/presentation/widgets/textfields/custom_textfield.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
import 'package:coment_app/src/feature/chat/bloc/conversations_cubit.dart';
import 'package:coment_app/src/feature/chat/presentation/widgets/chat_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class MessagePage extends StatefulWidget implements AutoRouteWrapper {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    final token = context.repository.authRepository.user?.accessToken;
    if (token == null) {
      return const Scaffold(
        body: Center(child: Text('Не авторизован')),
      );
    }
    return BlocProvider(
      create: (context) => ConversationsCubit(context.repository.chatRepository)
        ..loadConversations(token),
      child: this,
    );
  }
}

class _MessagePageState extends State<MessagePage> {
  String searchQuery = '';
  StreamSubscription? _conversationsSubscription;

  late final TextEditingController searchController;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatRepo = context.repository.chatRepository;
      final token = context.repository.authRepository.user?.accessToken;
      if (token != null) {
        _conversationsSubscription =
            chatRepo.conversationsUpdateStream.listen((_) {
          if (mounted) {
            context.read<ConversationsCubit>().loadConversations(token);
          }
        });
      }
    });
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    _conversationsSubscription?.cancel();
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    setState(() {
      searchController.clear();
      searchQuery = '';
      focusNode.unfocus();
    });
  }

  int? _extractCompanyId(String? title) {
    final match = RegExp(r'company-(\d+)').firstMatch(title ?? '');
    return match != null ? int.parse(match.group(1)!) : null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConversationsCubit, ConversationsState>(
      listener: (context, state) {
        state.maybeWhen(
          error: (message) => Toaster.showErrorTopShortToast(context, message),
          orElse: () {},
        );
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(
            btnBack: true,
            actions: [
              // const Expanded(flex:  1, child: SizedBox()),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
                  child: CustomTextField(
                    focusNode: focusNode,
                    controller: searchController,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    hintText: context.localized.search,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
              ),
              // const Expanded(flex: 1, child: SizedBox()),
            ],
          ),
          body: state.maybeWhen(
            orElse: () {
              return null;
            },
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (conversations) {
              // 1. Достаем текущего пользователя из репозитория
              final currentUser = context.repository.authRepository.user;

              if (currentUser == null) {
                return const Center(child: Text('Ошибка авторизации'));
              }

              final filteredConversations = conversations.where((conv) {
                // Ищем по заголовку (title) или по имени партнера (если есть)
                final title = conv.title?.toLowerCase() ?? '';
                final partnerName = conv.partner?.name?.toLowerCase() ?? '';

                return title.contains(searchQuery) ||
                    partnerName.contains(searchQuery);
              }).toList();
              // if (conversations.isEmpty) {
              //   return const Center(child: Text('Нет сообщений'));
              // }
              if (filteredConversations.isEmpty) {
                return Center(
                  child: Text(
                    searchQuery.isEmpty ? 'Нет сообщений' : 'Ничего не найдено',
                  ),
                );
              }
              return ListView.builder(
                // itemCount: conversations.length,
                itemCount: filteredConversations.length,
                itemBuilder: (context, index) {
                  // final conv = conversations[index];
                  final conv = filteredConversations[index];
                  // 2. Логика определения названия чата (перенесена из ChatListItem)
                  final displayName =
                      conv.title != null && conv.title!.isNotEmpty
                          ? conv.title
                          : (conv.partner?.name ?? 'Неизвестный');

                  String chatTitle;
                  if (currentUser.role == 'owner') {
                    chatTitle = displayName ?? 'Пользователь';
                  } else {
                    final companyId = _extractCompanyId(conv.title);
                    chatTitle = companyId != null
                        ? 'Компания #$companyId'
                        : (displayName ?? 'Чат');
                  }
                  return ChatListItem(
                    conversation: conv,
                    onTap: () async {
                      _clearSearch();
                      // Ждем, пока пользователь выйдет из чата
                      await context.router.push(
                        ChatRoute(
                          conversationId: conv.id,
                          companyName: chatTitle,
                          currentUser: currentUser,
                          accessToken: currentUser.accessToken!,
                          targetUser: conv.partner!,
                        ),
                      );
                      // Когда вернулись — обновляем список
                      if (mounted) {
                        final token =
                            // ignore: use_build_context_synchronously
                            context.repository.authRepository.user?.accessToken;
                        if (token != null) {
                          // ignore: use_build_context_synchronously
                          context
                              .read<ConversationsCubit>()
                              .loadConversations(token);
                        }
                      }
                    },
                  );
                },
              );
            },
            error: (message) => Center(child: Text('Ошибка: $message')),
          ),
        );
      },
    );
  }
}
