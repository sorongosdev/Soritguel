/// audio_streamer.dart
import 'dart:convert';
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audio_streamer/audio_streamer.dart';
import 'package:flutter_project/constants/ZerothDefine.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:typed_data';
import 'package:web_socket_channel/io.dart';
import 'dart:isolate';

import 'dart:typed_data';
import 'dart:math' as math;

class mAudioStreamer {
  ///proivder 관련 변수
  ValueNotifier<bool> isRecording =
      ValueNotifier<bool>(false); // 오디오 객체를 공유하기 위함, 녹음 중인지에 관한 변수
  final ValueNotifier<List<String>> receivedText = ValueNotifier<List<String>>(
      []); // 서버에서 받은 변수, 여러 줄일 수 있기 때문에 List<String> 타입

  bool isSpeaking = false; // 말하고 있는 중인지

  ///오디오 스트리머 세팅 관련 변수들
  dynamic _audioStreamer; // 오디오스트리머 객체

  int sampleRate = ZerothDefine.ZEROTH_RATE_44; // 샘플링율
  List<double> prevAudio = []; // audio 이전의 버퍼
  List<double> pastAudio = []; // prevAudio 이전의 버퍼
  List<double> audio = []; // 현재 버퍼
  bool isBufferUpdated = false;

  StreamSubscription<List<double>>? audioSubscription;
  DateTime? lastSpokeAt; // 마지막 말한 시점의 시간

  ReceivePort receivePort = ReceivePort(); // 수신 포트 설정
  IOWebSocketChannel? channel; // 웹소켓 채널 객체

  // double? dynamic_energy_adjustment_damping = 0.15;
  // double? dynamic_energy_ratio = 1.5; // 민감도: 높은 값을 잡을 수록 작은 소리에는 오디오 전송을 시작하지 않음
  double? energy_threshold = 0.1;
  double? energy;
  bool? prevSpeakingState;

  double minBufferSize = ZerothDefine.ZEROTH_RATE_44 / 2;
  double? lte; // 장기 에너지
  List<double> newAudio = [];
  double threshold =
      ZerothDefine.RESTING_THRESHOLD; // 음성 감지 감도. 데시벨 단위는 음수이기 때문에 이 값이 낮을수록 감지를 더 잘함
  double lte_ratio = ZerothDefine.LTE_RATIO;
  double ste_ratio = ZerothDefine.STE_RATIO;
  double? ste;
  double? lte_start = -80;

  mAudioStreamer() {
    _init();
    receivePort.listen((message) {
      //서버로부터 메시지를 받음
      // 모든 데이터를 받으면 웹소켓 채널을 닫음
      if (message == "END_OF_DATA") {
        // 서버가 모든 데이터를 받았다는 메시지를 받으면
        print("vad: EOD");
        channel?.sink.close(); // 웹소켓 채널 닫음
        audio.clear(); // 오디오 데이터
        prevAudio.clear();
        receivedText.value = List.empty(); // 녹음이 중지되면 서버에서 받아오기 위해 사용했던 변수를 비워줌
      } else {
        // 서버로부터 메시지를 받아 저장
        receivedText.value = List.empty(); // 실시간으로 받아오고 있기 때문에, 받아올 때마다 비워주어야함.
        // print("eod: msg $message");
        receivedText.value = List.from(receivedText.value)..add(message);
      }
    });
  }

  ///오디오 객체 초기화
  Future<void> _init() async {
    _audioStreamer = AudioStreamer();
    prevSpeakingState = false;
  }

  /// 권한이 허용됐는지 체크
  Future<bool> checkPermission() async => await Permission.microphone.isGranted;

  /// 마이크 권한 요청
  Future<void> requestPermission() async =>
      await Permission.microphone.request();

  ///오디오 샘플링 시작
  Future<void> startRecording() async {
    //권한 체크
    if (!(await checkPermission())) {
      await requestPermission();
    }

    prevSpeakingState = false;

    // 샘플링율 - 안드로이드에서만 동작
    _audioStreamer.sampleRate = sampleRate;

    // 오디오 스트림 시작
    audioSubscription =
        _audioStreamer.audioStream.listen(onAudio, onError: handleError);

    //마지막 말하는 중이었던 시간 업데이트
    lastSpokeAt = DateTime.now();

    lte = null;

    // 녹음중 유무 변수를 업데이트
    isRecording.value = true;
  }

  /// 오디오 샘플링을 멈추고 변수를 초기화
  Future<void> stopRecording() async {
    audio.clear();
    // 의미 없는 오디오 조건:
    // 현재 오디오 의미 없을 때 이전 오디오만 전송
    if (audio.length < minBufferSize) {
      print("vad: current useless audio.");
      sendAudio(audioBuffer: prevAudio, isFinal: true);
    }
    // 현재 오디오 의미 있을 때 현재 오디오를 전송
    else {
      // print("eod: useful current audio. send prev, current audio");
      print("vad: current meaningful audio.");
      sendAudio(audioBuffer: prevAudio, isFinal: false);
      sendAudio(audioBuffer: newAudio, isFinal: true);
    }

    audioSubscription?.cancel();
    isBufferUpdated = false;
    lastSpokeAt = null;
    isRecording.value = false;
  }

  /// 오디오 샘플링 콜백
  void onAudio(List<double> buffer) async {
    // 버퍼에 음성 데이터를 추가
    audio.addAll(buffer);

    // 버퍼의 데시벨 단위의 STE 계산
    ste = getRMS(buffer);

    // if (lte == null) { // 맨 처음의 lte 값을 lte_start에 저장
    //   lte = ste;
    //   lte_start = lte; // 맨 처음 lte의 값을 lte_start에 저장
    // }
    // else {
    //   // LTE 업데이트
    //   lte = lte_ratio * lte! + ste_ratio * ste!; // 지수 가중 평균 이용
    // }
    lte = lte_start;

    if (isSpeaking) {
      newAudio = List.from(audio);
    }

    // 말마디 감지 로직
    updateSpeakingStatus();

    checkSilence();

    // 오디오 버퍼가 6400씩 증가할 때마다 로그가 한번 찍힘
    print(
        "vad: isSpeaking $isSpeaking // STE = $ste // LTE = $lte // audio.length ${newAudio.length}");
  }

  /// 음성 데시벨의 rms에 따라 isSpeaking을 업데이트해주는 메소드
  void updateSpeakingStatus() {
    if (!isSpeaking) {
      threshold = ZerothDefine.RESTING_THRESHOLD; // false일 때 감지 감도는 기본 감지 감도
      if (ste! > lte! * threshold) {
        isSpeaking = true;
        print("vad: 말마디 시작됨");
      }
    } else if (isSpeaking) {
      threshold = ZerothDefine.SPEAKING_THRESHOLD; // 말하는 중일 때는 감도를 낮춰 말마디 감지를 더 잘하게 함(이 값은 감도와 반비례)
      if (ste! <= lte! * threshold && newAudio.length > 6400 * 2) {
        isSpeaking = false;
        lastSpokeAt = DateTime.now();
        print("vad: 말마디 끝남");

        pastAudio = List.from(prevAudio);
        prevAudio = List.from(newAudio);
        sendAudio(audioBuffer: pastAudio, isFinal: false);

        newAudio.clear();
        audio.clear();
        // lte = ste!; // 말마디가 끊겼을 때 lte를 조정해줌
        lte = lte_start; // 말마디가 끊겼을 때 lte를 조정해줌
      }
    }
  }

  /// 오디오 버퍼를 받아 데시벨로 리턴
  double getRMS(List<double> buffer) {
    double sumOfSquares = buffer.fold(0.0, (sum, value) => sum + value * value);
    double meanSquare = sumOfSquares / buffer.length;
    double ste = 20 * log(meanSquare) / ln10; // 평균 제곱 에너지 값을 데시벨로 변환
    return ste;
  }

  ///웹소켓 통신으로 실제로 wav를 isolate로 전송
  void sendAudio({required List<double> audioBuffer, required bool isFinal}) {
    // 원시 오디오 데이터인 PCM을 wav로 변환
    var wavData = transformToWav(audioBuffer);

    print("vad: sendAudio bufferSize ${audioBuffer.length}");

    // minBufferSize 이상일 때만 전송
    if (audioBuffer.isNotEmpty) {
      print("vad: sendAudio bufferSize in if ${audioBuffer.length}");

      // 웹소켓을 통해 wav 전송

      Isolate.spawn(sendOverWebSocket, {
        'wavData': wavData,
        'sendPort': receivePort.sendPort,
        'isFinal': isFinal, // 마지막 데이터인지 나타내는 변수 추가
      });
    }
  }

  ///웹소켓 통신 정보를 stream에 추가하고, 서버로부터 응답을 받는 부분
  static void sendOverWebSocket(Map<String, dynamic> args) async {
    final wavData = args['wavData'];
    final sendPort = args['sendPort'];
    final isFinal = args['isFinal'];

    //채널 설정
    final channel = IOWebSocketChannel.connect(ZerothDefine.MY_URL_test);

    //wav 파일을 base64로 인코딩
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

  ///침묵을 감지하는 함수
  void checkSilence() {
    if (!isSpeaking &&
        lastSpokeAt != null &&
        DateTime.now().difference(lastSpokeAt!).inSeconds >= 3) {
      stopRecording();
      Fluttertoast.showToast(msg: "침묵이 감지되었습니다.");
      print('vad: silence detected // ${DateTime.now()}');
    }
  }

  /// 오디오 PCM을 wav로 바꾸는 함수
  Uint8List transformToWav(List<double> pcmData) {
    int numSamples = pcmData.length;
    int numChannels = ZerothDefine.ZEROTH_MONO;
    int sampleSize = 2; // 16 bits#########

    int byteRate = sampleRate * numChannels * sampleSize;

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
    header.setUint32(24, sampleRate, Endian.little);
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
}
