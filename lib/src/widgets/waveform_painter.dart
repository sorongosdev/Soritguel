import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_project/src/audio_streamer.dart';
import 'package:flutter_project/src/utils/list_extensions.dart';
import 'package:provider/provider.dart';

import '../../models/waveform_model.dart';

class WaveformView extends StatefulWidget {
  final mAudioStreamer audioStreamer;
  final waveFormWidth;
  final waveFormHeight;

  const WaveformView({
    super.key,
    required this.audioStreamer,
    required this.waveFormHeight,
    required this.waveFormWidth,
  });

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
    final waveFormModel = Provider.of<WaveformModel>(context, listen: false);
    widget.audioStreamer.audioDataNotifier.addListener(() {
      waveFormModel.updateWaveform(widget.audioStreamer.audioDataNotifier
          .value); // audioDataNotifier.value가 업데이트되면 그걸 바탕으로 waveform을 업데이트
    });
  }

  @override
  void dispose() {
    // 리스너 제거
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WaveformModel>(
      builder: (context, model, child) {
        return CustomPaint(
          painter: WaveformPainter(model.ampList, rectWidth, model.tick),
          child: Container(
            width: widget.waveFormWidth,
            height: widget.waveFormHeight,
          ),
        );
      },
    );
  }
}

class WaveformPainter extends CustomPainter {
  List<double> ampList; // 소리 세기가 담겨있는 리스트
  double rectWidth; // 그릴 직사각형 넓이
  int tick;

  WaveformPainter(this.ampList, this.rectWidth, this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blue; // 파란색으로 그림

    final maxRect = size.width ~/ rectWidth; // 한 화면에 그려질 수 있는 사각형 수
    List<double> amps = ampList.take(tick).toList(); // tick 만큼의 진폭데이터를 가져
    if (amps.length > maxRect) { // amps 리스트의 길이가 한 화면에 그려질 수 있는 사각형 개수를 넘어가면 사각형 개수만큼만 amps 리스트의 최신값만 반환
      amps = amps.takeLast(maxRect).toList();
    }

    for (int i = 0; i < amps.length; i++) {
      final double amplitude = amps[i];
      // 사각형의 최대 높이를 size.height / 2로 제한
      final double maxAmpSize = size.height;
      // 실제 사각형 높이 계산 시 size.height를 고려해 그 이상인 진폭이면 최대높이만 그림
      final double actualAmpSize = min(amplitude * 100, maxAmpSize);
      final rect = Rect.fromLTWH(
        i * rectWidth, // left
        (size.height / 2) - actualAmpSize / 2, // top - 할당된 높이의 중심에 그림
        rectWidth - 5, // width
        actualAmpSize, // height
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
