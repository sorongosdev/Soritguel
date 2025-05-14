// lib/repositories/audio_repository.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:web_socket_channel/io.dart';

import '../constants/zeroth_define.dart';
import '../models/audio_sample.dart';
import 'package:audio_streamer/audio_streamer.dart';

typedef SilenceDetectedCallback = void Function();

class AudioRepository {
  // 오디오 스트리머 인스턴스
  final _audioStreamer = AudioStreamer();

  // 스트림 컨트롤러
  final _amplitudeController = StreamController<AudioSample>.broadcast();
  final _textController = StreamController<RecognizedText>.broadcast();
  final _bufferController = StreamController<AudioBuffer>.broadcast();

  // 상태 변수
  List<double> _audioBuffer = [];
  DateTime? _lastSpokeAt;
  bool _isSpeaking = false;
  final double _threshold = 0.1;

  // 웹소켓 및 Isolate 통신
  ReceivePort _receivePort = ReceivePort();
  IOWebSocketChannel? _channel;

  StreamSubscription? _audioSubscription;

  // 공개 스트림
  Stream<AudioSample> get amplitudeStream => _amplitudeController.stream;
  Stream<RecognizedText> get textStream => _textController.stream;
  Stream<AudioBuffer> get bufferStream => _bufferController.stream;

  AudioRepository() {
    // 수신 포트 리스너 설정
    _receivePort.listen(_handleReceivedMessage);
  }

  // 서버로부터 받은 메시지 처리
  void _handleReceivedMessage(dynamic message) {
    if (message == "END_OF_DATA") {
      _channel?.sink.close();
      _textController.add(RecognizedText(
        text: '',
        timestamp: DateTime.now(),
        isFinal: true,
      ));
    } else {
      _textController.add(RecognizedText(
        text: message,
        timestamp: DateTime.now(),
        isFinal: false,
      ));
    }
  }

  // 녹음 시작
  Future<void> startRecording() async {
    // 샘플링율 설정 (안드로이드에서만 동작)
    _audioStreamer.sampleRate = ZerothDefine.ZEROTH_RATE_44;

    // 오디오 스트림 구독
    _audioSubscription =
        _audioStreamer.audioStream.listen(_processAudioData, onError: (error) {
      print("Audio Stream Error: $error");
    });

    // 마지막 음성 감지 시간 초기화
    _lastSpokeAt = DateTime.now();
  }

  // 오디오 데이터 처리
  void _processAudioData(List<double> buffer) {
    // 버퍼에 오디오 데이터 추가
    _audioBuffer.addAll(buffer);

    // 버퍼를 AudioBuffer 모델로 변환하여 스트림에 추가
    _bufferController.add(AudioBuffer(
      samples: List.from(buffer), // 복사본 생성
      sampleRate: ZerothDefine.ZEROTH_RATE_44,
    ));

    // 일정 크기가 되면 서버로 전송
    if (_audioBuffer.length >= 44100 * 3) {
      _sendAudioData(isFinal: false);
    }

    // 최대 진폭 계산
    double maxAmp = buffer.reduce(max);

    // 진폭 스트림에 AudioSample 모델로 전송
    _amplitudeController.add(AudioSample(
      amplitude: maxAmp,
      timestamp: DateTime.now(),
      isSpeaking: maxAmp > _threshold,
    ));

    // 음성 감지 로직
    if (maxAmp > _threshold && !_isSpeaking) {
      _isSpeaking = true;
      _lastSpokeAt = DateTime.now();
    } else if (maxAmp <= _threshold) {
      _isSpeaking = false;
    }

    // 침묵 체크
    checkSilence();
  }

  // 침묵 감지
  Function? onSilenceDetected;

  void checkSilence() {
    if (!_isSpeaking &&
        _lastSpokeAt != null &&
        DateTime.now().difference(_lastSpokeAt!).inSeconds >= 3) {
      // 콜백이 설정된 경우 콜백 호출, 아니면 기존 방식 유지
      if (onSilenceDetected != null) {
        onSilenceDetected!();
      } else {
        stopRecording();
      }
    }
  }

  // 녹음 중지
  Future<void> stopRecording() async {
    print('AudioRepository: 녹음 중지 시작');

    // 음성 데이터가 있고 충분한 길이라면 서버로 전송
    if (_audioBuffer.isNotEmpty &&
        _audioBuffer.length > 44100 / 2 &&
        _audioBuffer.reduce(max) > _threshold) {
      _sendAudioData(isFinal: true);
    }

    // 오디오 스트림 구독 취소
    await _audioSubscription?.cancel();
    _audioSubscription = null;

    // 버퍼 초기화
    _audioBuffer.clear();
    _lastSpokeAt = null;

    print('AudioRepository: 녹음 중지 완료');
  }

  // 오디오 데이터 서버로 전송
  void _sendAudioData({required bool isFinal}) {
    String base64Data = _transformAudioToBase64(_audioBuffer);

    // Isolate를 이용해 웹소켓 통신
    Isolate.spawn(_sendOverWebSocket, {
      'wavData': base64Data,
      'sendPort': _receivePort.sendPort,
      'isFinal': isFinal,
    });

    // 버퍼 초기화
    _audioBuffer.clear();
  }

  // 오디오 데이터를 Base64로 변환
  String _transformAudioToBase64(List<double> audio) {
    // double 값을 16비트 정수로 변환하기 위한 ByteData 객체 생성
    ByteData byteData = ByteData(audio.length * 2); // 16비트 정수는 2바이트

    for (int i = 0; i < audio.length; i++) {
      // 각 double 값을 16비트 정수로 변환하여 ByteData에 설정
      int sample = (audio[i] * 32767.0)
          .round()
          .clamp(-32768, 32767); // double을 16비트 정수로 변환
      byteData.setInt16(i * 2, sample, Endian.little);
    }

    Uint8List bytes = byteData.buffer.asUint8List(); // ByteData를 Uint8List로 변환
    return base64Encode(bytes); // Uint8List를 base64로 인코딩
  }

  // 웹소켓을 통한 데이터 전송 (Isolate에서 실행)
  static void _sendOverWebSocket(Map<String, dynamic> args) async {
    final wavData = args['wavData'];
    final sendPort = args['sendPort'];
    final isFinal = args['isFinal'];

    // 웹소켓 채널 연결
    final channel = IOWebSocketChannel.connect(ZerothDefine.MY_URL_test);

    // 데이터 전송
    channel.sink.add(jsonEncode({
      'wavData': wavData,
      'isFinal': isFinal,
    }));

    // 서버로부터의 응답을 메인 Isolate로 전송
    channel.stream.listen((message) {
      sendPort.send(message);
    });
  }

  // 리소스 해제
  void dispose() {
    _audioSubscription?.cancel();
    _amplitudeController.close();
    _textController.close();
    _bufferController.close();
    _receivePort.close();
  }
}
