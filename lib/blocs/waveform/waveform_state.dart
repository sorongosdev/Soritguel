// lib/blocs/waveform/waveform_state.dart
import 'package:equatable/equatable.dart';
import '../../models/waveform_data.dart';

class WaveformState extends Equatable {
  final WaveformData waveformData;
  final bool isVisible;

  const WaveformState({
    required this.waveformData,
    this.isVisible = true,
  });

  /// 초기 상태 - 빈 파형
  factory WaveformState.initial() {
    return WaveformState(
      waveformData: WaveformData.empty(),
    );
  }

  /// 진폭 값 getter (편의 메서드)
  double get amplitude => waveformData.amplitude;

  /// 파형 막대 높이 배열 getter (편의 메서드)
  List<double> get barHeights => waveformData.barHeights;

  WaveformState copyWith({
    WaveformData? waveformData,
    bool? isVisible,
  }) {
    return WaveformState(
      waveformData: waveformData ?? this.waveformData,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  List<Object> get props => [waveformData, isVisible];
}