import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_project/src/audio_streamer.dart';
import 'package:flutter_project/src/utils/list_extensions.dart';

class WaveformView extends StatefulWidget {
  final mAudioStreamer audioStreamer;
  final waveFormWidth;
  final waveFormHeight;

  WaveformView({
    Key? key,
    required this.audioStreamer,
    required this.waveFormHeight,
    required this.waveFormWidth,
  }) : super(key: key);

  @override
  _WaveformViewState createState() => _WaveformViewState();
}

class _WaveformViewState extends State<WaveformView> {
  List<double> ampList = [];
  final double rectWidth = 15.0;
  int tick = 0;

  @override
  void initState() {
    super.initState();
    // audioDataNotifier의 리스너 추가
    widget.audioStreamer.audioDataNotifier.addListener(_updateWaveform);
  }

  @override
  void dispose() {
    // 리스너 제거
    widget.audioStreamer.audioDataNotifier.removeListener(_updateWaveform);
    super.dispose();
  }

  /// audioDataNotifier의 값이 변경될 때 호출될 메서드
  void _updateWaveform() {
    setState(() {
      ampList = widget.audioStreamer.audioDataNotifier.value;
      tick++;
      print("waveform: ampList size ${ampList.length}");
    });
  }

  // void replayAmplitude() {
  //   setState(() {
  //     tick++;
  //   });
  // }

  // void clearData() {
  //   setState(() {
  //     ampList.clear();
  //   });
  // }
  //
  // void clearWave() {
  //   setState(() {
  //     ampList.clear();
  //     tick = 0;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WaveformPainter(ampList, rectWidth, tick),
      child: Container(
        width: widget.waveFormWidth,
        height: widget.waveFormHeight,
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  List<double> ampList;
  double rectWidth;
  int tick;

  WaveformPainter(this.ampList, this.rectWidth, this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blue;

    final maxRect = size.width ~/ rectWidth; // 한 화면에 그려질 수 있는 사각형 수
    List<double> amps = ampList.take(tick).toList();
    if (amps.length > maxRect) {
      amps = amps.takeLast(maxRect).toList();
    }

    print("waveform: amps $amps");

    for (int i = 0; i < amps.length; i++) {
      final double amplitude = amps[i];
      // 사각형의 최대 높이를 size.height / 2로 제한
      final double maxAmpSize = size.height;
      // 실제 사각형 높이 계산 시 size.height를 고려
      final double actualAmpSize = min(amplitude * 100, maxAmpSize);
      final rect = Rect.fromLTWH(
        i * rectWidth, //left
        (size.height / 2) - actualAmpSize / 2, //top
        rectWidth - 5, //width
        actualAmpSize, //height
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
