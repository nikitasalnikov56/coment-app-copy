// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/presentation/widgets/dialog/toaster.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/auth/models/user_dto.dart';
import 'package:coment_app/src/feature/chat/bloc/chat_cubit.dart';
import 'package:coment_app/src/feature/chat/model/chat_message_dto.dart';
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

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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
          appBar: CustomAppBar(
            title: widget.companyName,
           
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
                        return _buildMessageBubble(message, isOwnMessage);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10,),
              _buildInputArea(),
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
          FloatingActionButton(
            backgroundColor: AppColors.mainColor,
            mini: true,
            onPressed: _sendMessage,
            child: SvgPicture.asset(
              AssetsConstants.icSend,
              color: Colors.white,
              width: 20,
              height: 20,
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
