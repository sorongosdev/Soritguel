// lib/blocs/waveform/waveform_event.dart
import 'package:equatable/equatable.dart';

abstract class WaveformEvent extends Equatable {
  const WaveformEvent();

  @override
  List<Object> get props => [];
}

class UpdateWaveform extends WaveformEvent {
  final double amplitude;

  const UpdateWaveform(this.amplitude);

  @override
  List<Object> get props => [amplitude];
}

class ClearWaveform extends WaveformEvent {}

// 추가: 파형 표시 토글 이벤트
class ToggleWaveformVisibility extends WaveformEvent {}