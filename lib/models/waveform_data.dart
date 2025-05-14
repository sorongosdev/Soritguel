// lib/models/waveform_data.dart
import 'package:equatable/equatable.dart';

/// 파형 데이터 모델
/// 오디오 진폭에 기반한, 화면에 표시할 파형 데이터를 나타냄
class WaveformData extends Equatable {
  final double amplitude;
  final DateTime timestamp;
  final List<double> barHeights; // 파형 막대 높이 목록

  const WaveformData({
    required this.amplitude,
    required this.timestamp,
    this.barHeights = const [],
  });

  /// 현재 진폭 값으로 새로운 파형 막대 높이 배열 생성
  factory WaveformData.generate(double amplitude, int barCount) {
    final now = DateTime.now();
    final bars = List<double>.generate(
      barCount,
      (index) => amplitude * (0.3 + 0.7 * (index % 3) / 3), // 자연스러운 파형을 위한 변형
    );
    
    return WaveformData(
      amplitude: amplitude,
      timestamp: now,
      barHeights: bars,
    );
  }

  /// 진폭이 0인 빈 파형 데이터 생성
  factory WaveformData.empty() {
    return WaveformData(
      amplitude: 0.0,
      timestamp: DateTime.now(),
      barHeights: const [],
    );
  }

  /// 파형 생성 (진폭 값만 변경)
  WaveformData withAmplitude(double newAmplitude) {
    return WaveformData(
      amplitude: newAmplitude,
      timestamp: DateTime.now(),
      barHeights: barHeights,
    );
  }

  @override
  List<Object> get props => [amplitude, timestamp, barHeights];
}