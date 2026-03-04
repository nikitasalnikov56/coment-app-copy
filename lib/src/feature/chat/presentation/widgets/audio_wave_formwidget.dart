import 'package:flutter/material.dart';
import 'package:just_waveform/just_waveform.dart';

class AudioWaveformWidget extends StatelessWidget {
  final Waveform waveform;
  final Duration start;
  final Duration duration;
  final Duration progress;
  final Color waveColor;
  final Color inactiveColor;
  final Function(Duration) onSeek;

  const AudioWaveformWidget({
    super.key,
    required this.waveform,
    required this.start,
    required this.duration,
    required this.progress,
    required this.waveColor,
    required this.inactiveColor,
    required this.onSeek,
  });

// Вспомогательный метод для расчета времени по координате X
  void _handleSeek(Offset localPosition, double width) {
    double relativePos = localPosition.dx / width;
    relativePos = relativePos.clamp(0.0, 1.0); // Чтобы не вышли за границы

    final seekMillis = duration.inMilliseconds * relativePos;
    onSeek(Duration(milliseconds: seekMillis.toInt()));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      return GestureDetector(
        onTapDown: (details) {
          _handleSeek(details.localPosition, width);
        },
        // 2. Срабатывает, когда только коснулись и начали держать
        onPanDown: (details) => _handleSeek(details.localPosition, width),

        // 3. Срабатывает при движении пальцем
        onPanUpdate: (details) => _handleSeek(details.localPosition, width),
        child: CustomPaint(
          size: Size.infinite,
          painter: AudioWaveformPainter(
            waveform: waveform,
            start: start,
            duration: duration,
            progress: progress,
            waveColor: waveColor,
            inactiveColor: inactiveColor,
            strokeWidth: 3.0,
            pixelsPerStep: 6.0,
          ),
        ),
      );
    });
  }
}

class AudioWaveformPainter extends CustomPainter {
  final Waveform waveform;
  final Duration start;
  final Duration duration;
  final Duration progress;
  final Color waveColor;
  final Color inactiveColor;
  final double strokeWidth;
  final double pixelsPerStep;

  AudioWaveformPainter({
    required this.waveform,
    required this.start,
    required this.duration,
    required this.progress,
    required this.waveColor,
    required this.inactiveColor,
    this.strokeWidth = 5.0,
    this.pixelsPerStep = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (duration == Duration.zero) return;

    final paintActive = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = waveColor;

    final paintInactive = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = inactiveColor;

    double width = size.width;
    double height = size.height;

    final waveformPixelsPerWindow = waveform.positionToPixel(duration).toInt();
    final waveformPixelsPerDevicePixel = waveformPixelsPerWindow / width;
    final waveformPixelsPerStep = waveformPixelsPerDevicePixel * pixelsPerStep;
    final sampleOffset = waveform.positionToPixel(start);

    // Определяем до какого пикселя рисовать "активный" цвет
    final progressPixel = waveform.positionToPixel(progress);

    for (var i = 0.0;
        i <= waveformPixelsPerWindow;
        i += waveformPixelsPerStep) {
      final sampleIdx = (sampleOffset + i).toInt();
      final x = i / waveformPixelsPerDevicePixel;

      final minY = _normalise(waveform.getPixelMin(sampleIdx), height);
      final maxY = _normalise(waveform.getPixelMax(sampleIdx), height);

      // Выбираем цвет: если текущий сэмпл меньше прогресса плеера — рисуем активным
      final currentPaint =
          (sampleOffset + i) < progressPixel ? paintActive : paintInactive;

      canvas.drawLine(
        Offset(x, minY),
        Offset(x, maxY),
        currentPaint,
      );
    }
  }

  double _normalise(int s, double height) {
    if (waveform.flags == 0) {
      final y = 32768 + s.clamp(-32768, 32767).toDouble();
      return height - (y * height / 65536);
    } else {
      final y = 128 + s.clamp(-128, 127).toDouble();
      return height - (y * height / 256);
    }
  }

  @override
  bool shouldRepaint(AudioWaveformPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
