import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/chat/bloc/chat_cubit.dart';
import 'package:coment_app/src/feature/chat/bloc/voice_recorder_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VoiceRecorderButton extends StatelessWidget {
  const VoiceRecorderButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          VoiceRecorderCubit(context.repository.voiceRepository),
      child: BlocConsumer<VoiceRecorderCubit, VoiceRecorderState>(
        listener: (context, state) {
          state.maybeWhen(
            success: (url, duration) {
              // Обращаемся напрямую к ChatCubit, который живет выше по дереву виджетов
              context.read<ChatCubit>().sendVoiceMessage(url, duration);

              // Сбрасываем кнопку обратно в состояние микрофона через метод кубита
              context.read<VoiceRecorderCubit>().reset();
            },
            error: (msg) => ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(msg))),
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.maybeWhen(
            recording: (_) => IconButton(
              icon: const Icon(Icons.stop_circle, color: Colors.red),
              onPressed: () => context.read<VoiceRecorderCubit>().stopAndSend(),
            ),
            uploading: () => const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            orElse: () => IconButton(
              color: Theme.of(context).appBarTheme.iconTheme?.color,
              onPressed: () => context.read<VoiceRecorderCubit>().start(),
              icon: const Icon(Icons.mic_none_rounded),
            ),
          );
        },
      ),
    );
  }
}

