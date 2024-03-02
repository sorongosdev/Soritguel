/// audio_streamer.dart
import 'dart:convert';
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audio_streamer/audio_streamer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:typed_data';
import 'package:web_socket_channel/io.dart';
import 'dart:isolate';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;

class mAudioStreamer {
  ///proivder 관련 변수
  ValueNotifier<bool> isRecording =
      ValueNotifier<bool>(false); // 오디오 객체를 공유하기 위함, 녹음 중인지에 관한 변수
  final ValueNotifier<List<String>> receivedText = ValueNotifier<List<String>>(
      []); // 서버에서 받은 변수, 여러 줄일 수 있기 때문에 List<String> 타입

  bool isSpeaking = false; // 말하고 있는 중인지
  List<bool> isSpeakingArr = [false, false, false];

  ///오디오 스트리머 세팅 관련 변수들
  dynamic _audioStreamer; // 오디오스트리머 객체

  int? sampleRate; // 샘플링율
  List<double> audio = [];
  StreamSubscription<List<double>>? audioSubscription;
  DateTime? lastSpokeAt; //마지막 말한 시점의 시간

  ReceivePort receivePort = ReceivePort(); // 수신 포트 설정
  IOWebSocketChannel? channel; //웹소켓 채널 객체

  mAudioStreamer() {
    _init();
    receivePort.listen((message) {
      //서버로부터 메시지를 받음
      // 모든 데이터를 받으면 웹소켓 채널을 닫음
      if (message == "END_OF_DATA") {
        // 서버가 모든 데이터를 받았다는 메시지를 받으면
        channel?.sink.close(); // 웹소켓 채널 닫음
        receivedText.value = List.empty(); // 녹음이 중지되면 서버에서 받아오기 위해 사용했던 변수를 비워줌
      } else {
        // 서버로부터 메시지를 받아 저장
        receivedText.value = List.empty(); // 실시간으로 받아오고 있기 때문에, 받아올 때마다 비워주어야함.
        print("msg: $message");
        receivedText.value = List.from(receivedText.value)..add(message);
      }
    });
  }

  ///오디오 객체 초기화
  Future<void> _init() async {
    _audioStreamer = AudioStreamer();
  }

  ///오디오 샘플링 시작
  Future<void> startRecording() async {
    if (!(await checkPermission())) {
      //권한 체크
      await requestPermission();
    }

    // 샘플링율 - 안드로이드에서만 동작
    _audioStreamer.sampleRate = 22100;

    // 오디오 스트림 시작
    audioSubscription =
        _audioStreamer.audioStream.listen(onAudio, onError: handleError);

    lastSpokeAt = DateTime.now(); //마지막 말하는 중이었던 시간 업데이트

    isRecording.value = true;
  }

  /// 오디오 샘플링을 멈추고 변수를 초기화
  Future<void> stopRecording() async {
    // 일정 버퍼 사이즈가 안되었어도 녹음이 중지됐으므로 나머지 오디오를 전송
    if (audio.isNotEmpty) {
      sendAudio(isFinal: true);
    }

    audioSubscription?.cancel();
    audio.clear(); // 오디오 데이터
    sampleRate = null; // 샘플링율
    lastSpokeAt = null;
    isRecording.value = false;
  }

  /// 권한이 허용됐는지 체크
  Future<bool> checkPermission() async => await Permission.microphone.isGranted;

  /// 마이크 권한 요청
  Future<void> requestPermission() async =>
      await Permission.microphone.request();

  /// 오디오 샘플링 콜백
  void onAudio(List<double> buffer) async {
    audio.addAll(buffer);

    // 샘플링율 감지
    getSampleRate();

    double threshold = 0.1; // 침묵 기준 진폭
    double maxAmp = buffer.reduce(max);

    // isSpeaking 업데이트
    updateSpeakingStatus(threshold, maxAmp);

    print("isSpeaking: $isSpeaking");

    // 3초 침묵 감지시 녹음 중지
    checkSilence();

    // 문장 감지 후 전송
    sendBySentence();
  }

  /// 음성의 진폭에 따라 isSpeaking, isSpeakingArr 업데이트해주는 메소드
  void updateSpeakingStatus(double threshold, double maxAmp) {
    // isSpeaking의 현재 상태 업데이트를 위해 리스트 shift
    isSpeakingArr[0] = isSpeakingArr[1]; // 인덱스1 값을 0으로 옮겨줌
    isSpeakingArr[1] = isSpeakingArr[2]; // 인덱스2 값을 1으로 옮겨줌

    if (maxAmp > threshold && !isSpeaking) {
      // 말하는 중인지 판단
      isSpeaking = true;
      lastSpokeAt = DateTime.now();
    } else {
      isSpeaking = false;
    }

    isSpeakingArr[2] = isSpeaking; // 현재 isSpeaking 상태를 인덱스2에 저장
  }

  ///침묵을 감지하는 함수
  void checkSilence() {
    if (!isSpeaking &&
        lastSpokeAt != null &&
        DateTime.now().difference(lastSpokeAt!).inSeconds >= 3) {
      stopRecording();
      Fluttertoast.showToast(msg: "침묵이 감지되었습니다.");
      print('Stopped recording due to silence.');
    }
  }

  /// 문장 단위로 전송
  void sendBySentence() {
    if (isSpeakingArr[0] && !isSpeakingArr[1] && !isSpeakingArr[2]) {
      sendAudio(isFinal: false);
    }
  }

  ///웹소켓 통신으로 실제로 wav를 isolate로 전송
  void sendAudio({required bool isFinal}) {
    print("send Audio / isfinal $isFinal");
    // 원시 오디오 데이터인 PCM을 wav로 변환
    var wavData = transformToWav(audio);

    // 웹소켓을 통해 wav 전송
    Isolate.spawn(sendOverWebSocket, {
      'wavData': wavData,
      'sendPort': receivePort.sendPort,
      'isFinal': isFinal, // 마지막 데이터인지 나타내는 변수 추가
    });

    // 버퍼를 비워줌
    audio.clear();
  }

  ///웹소켓 통신 정보를 stream에 추가하고, 서버로부터 응답을 받는 부분
  static void sendOverWebSocket(Map<String, dynamic> args) async {
    final wavData = args['wavData'];
    final sendPort = args['sendPort'];
    final isFinal = args['isFinal'];

    //채널 설정
    // final channel = IOWebSocketChannel.connect('ws://192.168.1.101:8080');
    final channel = IOWebSocketChannel.connect(
        'wss://www.voiceai.co.kr:8889/client/ws/flutter');

    // stream에 데이터를 추가
    // channel.sink.add(wavData);
    var base64WavData = base64Encode(wavData);

    // stream에 데이터를 추가
    channel.sink.add(jsonEncode({
      'wavData': base64WavData,
      'isFinal': isFinal,
    }));

    // 서버로부터의 응답을 받아 메인 Isolate로 전송
    channel.stream.listen((message) {
      sendPort.send(message);
    });
  }

  /// 오디오 PCM을 wav로 바꾸는 함수
  Uint8List transformToWav(List<double> pcmData) {
    // int sampleRate = 22100;
    print("transformToWav $sampleRate");
    int numSamples = pcmData.length;
    int numChannels = 1;
    int sampleSize = 2; // 16 bits#########

    int byteRate = sampleRate! * numChannels * sampleSize;

    var header = ByteData(44);
    var bData = ByteData(numSamples * sampleSize);

    // PCM 데이터를 Int16 형식으로 변환
    for (int i = 0; i < numSamples; ++i) {
      bData.setInt16(
          i * sampleSize, (pcmData[i] * 32767).toInt(), Endian.little);
    }

    // RIFF header
    header.setUint32(0, 0x46464952, Endian.little); // "RIFF"
    header.setUint32(4, 36 + numSamples * sampleSize, Endian.little);
    header.setUint32(8, 0x45564157, Endian.little); // "WAVE"

    // fmt subchunk
    header.setUint32(12, 0x20746D66, Endian.little); // "fmt "
    header.setUint32(16, 16, Endian.little); // SubChunk1Size
    header.setUint16(20, 1, Endian.little); // AudioFormat
    header.setUint16(22, numChannels, Endian.little);
    header.setUint32(24, sampleRate!, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, numChannels * sampleSize, Endian.little); // BlockAlign
    header.setUint16(34, 8 * sampleSize, Endian.little); // BitsPerSample

    // data subchunk
    header.setUint32(36, 0x61746164, Endian.little); // "data"
    header.setUint32(40, numSamples * sampleSize, Endian.little);

    var wavData = Uint8List(44 + numSamples * sampleSize);
    wavData.setAll(0, header.buffer.asUint8List());
    wavData.setAll(44, bData.buffer.asUint8List());

    return wavData;
  }

  /// 에러 핸들러
  void handleError(Object error) {
    isRecording.value = false; //에러 발생시 녹음 중지
    print(error);
  }

  Future<void> getSampleRate() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      if (!(iosInfo.isPhysicalDevice)) {
        // ios 에뮬레이터일 경우
        print("ios emulator");
        sampleRate = 44100;
      } else {
        sampleRate ??= await _audioStreamer.actualSampleRate;
      }
    } else {
      // 그 이외의 경우 샘플링율 자동 감지
      sampleRate ??= await _audioStreamer.actualSampleRate;
    }
  }
}
