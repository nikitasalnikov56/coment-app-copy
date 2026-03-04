import 'package:coment_app/src/feature/chat/data/voice_recorder_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:just_audio/just_audio.dart';

part 'voice_recorder_cubit.freezed.dart';

class VoiceRecorderCubit extends Cubit<VoiceRecorderState> {
  final IVoiceRepository _repository;

  VoiceRecorderCubit(this._repository)
      : super(const VoiceRecorderState.initial());

  Future<void> start() async {
    try {
      await _repository.startRecording();
      emit(VoiceRecorderState.recording(startTime: DateTime.now()));
    } catch (e) {
      emit(VoiceRecorderState.error(e.toString()));
    }
  }

  Future<void> stopAndSend() async {
    // DateTime? start;
    // state.maybeWhen(
    //   recording: (startTime) => start = startTime,
    //   orElse: () {},
    // );
    emit(const VoiceRecorderState.uploading());
    try {
      // final url = await _repository.stopAndUpload();
      final localPath = await _repository.stopRecording();
      // if (url != null && start != null) {
      //   final durationMs = DateTime.now().difference(start!).inMilliseconds;
      //   emit(VoiceRecorderState.success(url, durationMs));
      // } else {
      //   emit(const VoiceRecorderState.initial());
      // }
      if (localPath != null) {
        final player = AudioPlayer();
        final duration = await player.setFilePath(localPath);
        final durationMs = duration?.inMilliseconds ?? 0;
        await player.dispose();

        final url = await _repository.uploadFile(localPath);
        if (url != null) {
          emit(VoiceRecorderState.success(url, durationMs));
        } else{
          emit(const VoiceRecorderState.initial());
        }
      }
    } catch (e) {
      emit(VoiceRecorderState.error(e.toString()));
    }
  }

  void reset() => emit(const VoiceRecorderState.initial());
}

@freezed
class VoiceRecorderState with _$VoiceRecorderState {
  const factory VoiceRecorderState.initial() = _Initial;
  const factory VoiceRecorderState.recording({required DateTime startTime}) =
      _Recording;
  const factory VoiceRecorderState.uploading() = _Uploading;
  const factory VoiceRecorderState.success(String url, int durationMs) = _Success;
  const factory VoiceRecorderState.error(String message) = _Error;
}
