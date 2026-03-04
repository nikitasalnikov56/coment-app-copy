import 'dart:io';

import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/feature/chat/presentation/widgets/audio_wave_formwidget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class VoiceMessagePlayer extends StatefulWidget {
  final String url;
  final int duration; // в мс
  final bool isOwnMessage;

  const VoiceMessagePlayer({
    super.key,
    required this.url,
    required this.duration,
    required this.isOwnMessage,
  });

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Waveform? _waveform;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      // 1. Подготовка путей
      final tempDir = await getTemporaryDirectory();
      final audioFileName = '${widget.url.hashCode}.m4a';
      final waveFileName = '${widget.url.hashCode}.wave';

      final audioFile = File(p.join(tempDir.path, audioFileName));
      final waveFile = File(p.join(tempDir.path, waveFileName));

      // 2. Загрузка аудио если его нет
      if (!audioFile.existsSync()) {
        final response = await http.get(Uri.parse(widget.url));
        await audioFile.writeAsBytes(response.bodyBytes);
      }

      // 3. Установка в плеер
      await _audioPlayer.setFilePath(audioFile.path);

      // 4. Экстракция волны если её нет
      if (!waveFile.existsSync()) {
        final stream =
            JustWaveform.extract(audioInFile: audioFile, waveOutFile: waveFile);
        await for (var progress in stream) {
          if (progress.waveform != null) {
            _waveform = progress.waveform;
          }
        }
      } else {
        _waveform = await JustWaveform.parse(waveFile);
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint("Voice Init Error: $e");
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
          width: 200,
          height: 40,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }

    if (_errorMessage != null) {
      return const Icon(Icons.error_outline, color: Colors.red);
    }

    return Container(
      padding: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: widget.isOwnMessage
            ? AppColors.mainColor
            : AppColors.backgroundInputGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamBuilder<PlayerState>(
            stream: _audioPlayer.playerStateStream,
            builder: (context, snapshot) {
              final playing = snapshot.data?.playing ?? false;
              final processingState = snapshot.data?.processingState;

              return IconButton(
                onPressed: () {
                  if (playing) {
                    _audioPlayer.pause();
                  } else {
                    if (processingState == ProcessingState.completed) {
                      _audioPlayer.seek(Duration.zero);
                    }
                    _audioPlayer.play();
                  }
                },
                icon: Icon(
                  playing && processingState != ProcessingState.completed
                      ? Icons.pause
                      : Icons.play_arrow_rounded,
                  color: widget.isOwnMessage ? Colors.white : Colors.black,
                ),
              );
            },
          ),
          if (_waveform != null)
            StreamBuilder<Duration>(
              stream: _audioPlayer.positionStream,
              builder: (context, snapshot) {
                final currentPosition = snapshot.data ?? Duration.zero;
                return SizedBox(
                  width: 140,
                  height: 30,
                  child: AudioWaveformWidget(
                    waveform: _waveform!,
                    start: Duration.zero,
                    duration: _waveform!.duration,
                    // Добавляем прогресс для закрашивания
                    progress: currentPosition,
                    waveColor: widget.isOwnMessage
                        ? Colors.white
                        : AppColors.mainColor,
                    inactiveColor:
                        widget.isOwnMessage ? Colors.white38 : Colors.black26,
                    onSeek: (newPosition) {
                      _audioPlayer.seek(newPosition);
                    },
                  ),
                );
              },
            ),
          const SizedBox(width: 8),
          Text(
            _formatDuration(widget.duration),
            style: TextStyle(
              fontSize: 11,
              color: widget.isOwnMessage ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int ms) {
    final duration = Duration(milliseconds: ms);
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }
}

