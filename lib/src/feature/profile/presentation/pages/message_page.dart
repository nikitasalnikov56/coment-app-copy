import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/presentation/widgets/dialog/toaster.dart';
import 'package:coment_app/src/core/presentation/widgets/textfields/custom_textfield.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
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
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
                  child: CustomTextField(
                    contentPadding:const  EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    hintText: context.localized.search,
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
              if (conversations.isEmpty) {
                return const Center(child: Text('Нет сообщений'));
              }
              return ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conv = conversations[index];
                  return ChatListItem(
                    conversation: conv,

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

class MessageList extends StatelessWidget {
  const MessageList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationsCubit, ConversationsState>(
      builder: (context, state) {
        return const Placeholder();
      },
    );
  }
}
