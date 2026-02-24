import 'package:coment_app/src/feature/chat/data/voice_recorder_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

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
    emit(const VoiceRecorderState.uploading());
    try {
      final url = await _repository.stopAndUpload();
      if (url != null) {
        emit(VoiceRecorderState.success(url));
      } else {
        emit(const VoiceRecorderState.initial());
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
  const factory VoiceRecorderState.success(String url) = _Success;
  const factory VoiceRecorderState.error(String message) = _Error;
}
