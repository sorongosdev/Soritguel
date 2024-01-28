/// audio_recorder.dart
import 'package:flutter_sound/flutter_sound.dart';

class AudioRecorder {
  FlutterSoundRecorder? _AudioRecorder;
  bool _isRecording = false;

  AudioRecorder() {
    _init();
  }

  Future<void> _init() async {
    _AudioRecorder = FlutterSoundRecorder();
    await _AudioRecorder!.openRecorder();
  }

  Future<void> startRecording() async {
    await _AudioRecorder!.startRecorder(toFile: 'my_record.wav');
    _isRecording = true;
  }

  Future<void> stopRecording() async {
    await _AudioRecorder!.stopRecorder();
    _isRecording = false;
  }

  bool get isRecording => _isRecording;

  void dispose() {
    _AudioRecorder!.closeRecorder();
    _AudioRecorder = null;
  }
}
