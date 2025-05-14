// lib/blocs/waveform/waveform_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/waveform_data.dart';
import 'waveform_event.dart';
import 'waveform_state.dart';

class WaveformBloc extends Bloc<WaveformEvent, WaveformState> {
  static const int DEFAULT_BAR_COUNT = 10; // 기본 막대 개수

  WaveformBloc() : super(WaveformState.initial()) {
    on<UpdateWaveform>(_onUpdateWaveform);
    on<ClearWaveform>(_onClearWaveform);
    on<ToggleWaveformVisibility>(_onToggleWaveformVisibility);
  }

  void _onUpdateWaveform(UpdateWaveform event, Emitter<WaveformState> emit) {
    // 새 진폭 값으로 파형 데이터 생성
    final newWaveformData = WaveformData.generate(
      event.amplitude,
      DEFAULT_BAR_COUNT,
    );
    
    emit(state.copyWith(waveformData: newWaveformData));
  }

  void _onClearWaveform(ClearWaveform event, Emitter<WaveformState> emit) {
    emit(state.copyWith(waveformData: WaveformData.empty()));
  }

  void _onToggleWaveformVisibility(ToggleWaveformVisibility event, Emitter<WaveformState> emit) {
    emit(state.copyWith(isVisible: !state.isVisible));
  }
}