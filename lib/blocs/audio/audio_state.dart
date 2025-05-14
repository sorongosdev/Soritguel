// lib/blocs/audio/audio_state.dart
import 'package:equatable/equatable.dart';
import '../../models/audio_sample.dart';

enum AudioStatus { initial, recording, idle, error }

class AudioState extends Equatable {
  final AudioStatus status;
  final AudioSample? lastSample;
  final List<RecognizedText> recognizedTexts;
  final String? errorMessage;
  final bool isRecording;
  final AudioBuffer? lastBuffer;

  const AudioState({
    this.status = AudioStatus.initial,
    this.lastSample,
    this.recognizedTexts = const [],
    this.errorMessage,
    this.isRecording = false,
    this.lastBuffer,
  });

  // 모든 인식된 텍스트를 하나의 문자열로 합치기
  List<String> get textLines {
    return recognizedTexts.map((text) => text.text).toList();
  }

  // 현재 진폭 값 (없으면 0)
  double get amplitude {
    return lastSample?.amplitude ?? 0.0;
  }

  factory AudioState.initial() {
    return const AudioState();
  }

  AudioState copyWith({
    AudioStatus? status,
    AudioSample? lastSample,
    List<RecognizedText>? recognizedTexts,
    String? errorMessage,
    bool? isRecording,
    AudioBuffer? lastBuffer,
    bool clearError = false,
  }) {
    return AudioState(
      status: status ?? this.status,
      lastSample: lastSample ?? this.lastSample,
      recognizedTexts: recognizedTexts ?? this.recognizedTexts,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isRecording: isRecording ?? this.isRecording,
      lastBuffer: lastBuffer ?? this.lastBuffer,
    );
  }

  @override
  List<Object?> get props => [status, lastSample, recognizedTexts, errorMessage, isRecording, lastBuffer];
}