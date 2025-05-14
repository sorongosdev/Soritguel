import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/waveform/waveform_bloc.dart';
import '../blocs/waveform/waveform_state.dart';
import '../constants/waveform_const.dart';
import '../models/waveform_data.dart';

/// 오디오 파형을 표시하는 위젯
class WaveformView extends StatelessWidget {
  final double waveFormHeight;
  final double waveFormWidth;

  const WaveformView({
    Key? key,
    required this.waveFormHeight,
    required this.waveFormWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WaveformBloc, WaveformState>(
      builder: (context, state) {
        // 파형이 숨겨진 경우 빈 컨테이너 반환
        if (!state.isVisible) {
          return SizedBox(
            width: waveFormWidth,
            height: waveFormHeight,
          );
        }
        
        return CustomPaint(
          painter: WaveformPainter(state.waveformData),
          child: Container(
            width: waveFormWidth,
            height: waveFormHeight,
          ),
        );
      },
    );
  }
}

/// 오디오 파형을 그리는 CustomPainter
class WaveformPainter extends CustomPainter {
  final WaveformData waveformData;

  WaveformPainter(this.waveformData);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue; // 파란색으로 그림

    final rectWidth = WaveformConst.RECT_WIDTH;
    final halfMaxRect = size.width / rectWidth ~/ 2; // 한 화면에 그려질 수 있는 최대 사각형 개수의 절반
    
    // 막대 리스트가 비어있으면 진폭 값으로 실시간 생성
    final barHeights = waveformData.barHeights.isEmpty 
        ? List.generate(
            halfMaxRect, 
            (i) => waveformData.amplitude * WaveformConst.SCALE_FACTOR * (0.5 + 0.5 * (i % 3) / 3)
          )
        : waveformData.barHeights;
    
    // 각 막대 그리기
    for (int i = 0; i < barHeights.length && i < halfMaxRect; i++) {
      // 막대 높이 계산 (화면 크기에 맞게 제한)
      double barHeight = barHeights[i].clamp(0.0, size.height);
      
      // 사각형 정의
      final rect = Rect.fromLTWH(
        size.width / 4 + i * rectWidth, // left
        (size.height / 2) - barHeight / 2, // top (중앙 정렬)
        rectWidth - WaveformConst.RECT_SPACING, // width
        barHeight, // height
      );

      // 사각형 그리기
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is WaveformPainter) {
      return oldDelegate.waveformData != waveformData;
    }
    return true;
  }
}