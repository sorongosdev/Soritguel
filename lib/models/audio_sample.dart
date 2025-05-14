// lib/models/audio_sample.dart
import 'package:equatable/equatable.dart';

/// 오디오 샘플 데이터 모델
/// 오디오 스트리밍의 개별 샘플을 나타냄
class AudioSample extends Equatable {
  final double amplitude;
  final DateTime timestamp;
  final bool isSpeaking;

  const AudioSample({
    required this.amplitude,
    required this.timestamp,
    this.isSpeaking = false,
  });

  @override
  List<Object> get props => [amplitude, timestamp, isSpeaking];
}

/// 오디오 버퍼 모델
/// 오디오 샘플의 집합으로, 처리할 오디오 데이터를 나타냄
class AudioBuffer extends Equatable {
  final List<double> samples;
  final int sampleRate;
  final bool isFinal;

  const AudioBuffer({
    required this.samples,
    required this.sampleRate,
    this.isFinal = false,
  });

  /// 버퍼의 최대 진폭 계산
  double get maxAmplitude {
    if (samples.isEmpty) return 0.0;
    return samples.reduce((max, e) => e > max ? e : max);
  }

  /// 버퍼의 평균 진폭 계산
  double get averageAmplitude {
    if (samples.isEmpty) return 0.0;
    final sum = samples.fold(0.0, (sum, e) => sum + e.abs());
    return sum / samples.length;
  }

  /// 버퍼 길이(초) 계산
  double get durationInSeconds {
    return samples.length / sampleRate;
  }

  @override
  List<Object> get props => [samples, sampleRate, isFinal];
}

/// 인식된 텍스트 모델
/// STT 서비스로부터 받은 텍스트 결과를 나타냄
class RecognizedText extends Equatable {
  final String text;
  final DateTime timestamp;
  final bool isFinal;

  const RecognizedText({
    required this.text,
    required this.timestamp,
    this.isFinal = false,
  });

  @override
  List<Object> get props => [text, timestamp, isFinal];
}