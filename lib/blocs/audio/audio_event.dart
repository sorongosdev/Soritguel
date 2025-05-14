// lib/blocs/audio/audio_event.dart
import 'package:equatable/equatable.dart';
import '../../models/audio_sample.dart';

abstract class AudioEvent extends Equatable {
  const AudioEvent();

  @override
  List<Object> get props => [];
}

class StartRecording extends AudioEvent {}

class StopRecording extends AudioEvent {
  final bool silenceDetected;

  const StopRecording({this.silenceDetected = false});

  @override
  List<Object> get props => [silenceDetected];
}

class AudioSampleReceived extends AudioEvent {
  final AudioSample sample;

  const AudioSampleReceived(this.sample);

  @override
  List<Object> get props => [sample];
}

class AudioBufferReceived extends AudioEvent {
  final AudioBuffer buffer;

  const AudioBufferReceived(this.buffer);

  @override
  List<Object> get props => [buffer];
}

class RecognizedTextReceived extends AudioEvent {
  final RecognizedText recognizedText;

  const RecognizedTextReceived(this.recognizedText);

  @override
  List<Object> get props => [recognizedText];
}

class ClearRecognizedText extends AudioEvent {}
