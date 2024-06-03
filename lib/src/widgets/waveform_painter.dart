import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_project/constants/tag_const.dart';
import 'package:flutter_project/constants/waveform_const.dart';
import 'package:flutter_project/src/audio_streamer.dart';
import 'package:provider/provider.dart';

import '../../models/waveform_model.dart';

/// 오디오 파형을 보여줌
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
  final double rectWidth = WaveformConst.RECT_WIDTH; // 직사각형 폭

  @override
  void initState() {
    super.initState();
    // audioDataNotifier의 리스너 추가
    final waveformModel = Provider.of<WaveformModel>(context, listen: false);
    widget.audioStreamer.audioDataNotifier.addListener(() {
      waveformModel.updateWaveform(widget.audioStreamer.audioDataNotifier.value); // audioDataNotifier.value가 업데이트되면 그걸 바탕으로 waveform을 업데이트
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
          painter: WaveformPainter(model.newAmp, rectWidth),
          child: Container(
            width: widget.waveFormWidth,
            height: widget.waveFormHeight,
          ),
        );
      },
    );
  }
}

/// 오디오 파형을 그림
class WaveformPainter extends CustomPainter {
  double newAmp; // 현재 소리 세기
  double rectWidth; // 그릴 직사각형 넓이

  WaveformPainter(this.newAmp, this.rectWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue; // 파란색으로 그림

    final halfMaxRect = size.width / rectWidth ~/ 2; // 한 화면에 그려질 수 있는 최대 사각형 개수의 절반

    for (int i = 0; i < halfMaxRect; i++) {
      /// 현재 음성 진폭을 기반으로 랜덤한 실수를 얻음
      final double randomAmplitude = Random().nextDouble() * newAmp;
      /// 사각형의 최대 높이를 size.height로 제한
      final double maxAmpSize = size.height;
      /// Amplitude 값은 매우 작기 때문에 상수를 곱해 스케일링해줌
      final double actualAmpSize = min(randomAmplitude * WaveformConst.SCALE_FACTOR, maxAmpSize);

      // 사각형 정의
      final rect = Rect.fromLTWH(
        size.width / 4 + i * rectWidth, // left, 간격과 관련
        (size.height / 2) - actualAmpSize / 2, // top, 할당된 높이의 중심에 그림
        rectWidth - WaveformConst.RECT_SPACING, // width, 사각형의 간격에 해당하는 만큼 빼줌
        actualAmpSize, // height
      );

      // 사각형을 그림
      canvas.drawRect(rect, paint);
    }
}

@override
bool shouldRepaint(covariant CustomPainter oldDelegate) {
  return true;
}}
