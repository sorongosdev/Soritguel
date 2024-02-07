/// audio_recorder.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:isolate';
import 'package:fluttertoast/fluttertoast.dart';
import 'serializer.dart';
import 'package:intl/intl.dart';

class AudioRecorder {
  ReceivePort receivePort = ReceivePort();

  FlutterSoundRecorder? _AudioRecorder; // 오디오 객체
  ValueNotifier<bool> isRecording = ValueNotifier<bool>(false); // 오디오 객체를 공유하기 위함, 녹음 중인지에 관한 변수
  String? _filePath; // 녹음한 파일 경로를 저장하기 위한 변수
  final ValueNotifier<List<String>> receivedText = ValueNotifier<List<String>>([]); // 서버에서 받은 변수, 3줄이기 때문에 List<String> 타입
  // 서버로부터 메시지를 받아 토스트 메시지로 출력
  AudioRecorder() {
    _init();
    receivePort.listen((message) {
      // 받은 메시지 토스트로 출력
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      // 서버로부터 메시지를 받아 저장
      receivedText.value = List.from(receivedText.value)..add(message);
    });
  }

  /// 오디오 객체를 초기화하는 함수
  Future<void> _init() async {
    _AudioRecorder = FlutterSoundRecorder();
    await _AudioRecorder!.openRecorder();
  }

  /// 녹음 실행하는 함수
  Future<void> startRecording() async {
    Directory? directory; // wav 저장 경로 설정

    // 안드로이드와 iOS에서 다르게 처리
    if (Platform.isAndroid) {
      // 안드로이드: 외부 저장소 사용
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      // iOS: 앱 문서 디렉토리 사용
      directory = await getApplicationDocumentsDirectory();
    }

    // 현재 시간을 yyyyMMdd_HHmmss 형태로 포맷
    var now = DateTime.now();
    var formatter = DateFormat('yyyyMMdd_HHmmss');
    String formattedTime = formatter.format(now);

    // 녹음한 파일 경로를 저장 - iOS와 Android에서 다른 파일 형식 사용
    String extension = Platform.isIOS ? '.aac' : '.wav';
    _filePath = directory!.path + '/' + formattedTime + extension;
    await _AudioRecorder!.startRecorder(toFile: _filePath);
    isRecording.value = true;
  }

  /// 녹음 중지하는 함수
  Future<void> stopRecording() async {
    await _AudioRecorder!.stopRecorder();
    isRecording.value = false; // _isRecording 대신 isRecording 사용
    receivedText.value = List.empty(); // 녹음이 중지되면 서버에서 받아오기 위해 사용했던 변수를 비워줌

    // 파일 경로
    final file = File(_filePath!);
    final base64Str = await Serializer.serializeFile(file);  // 파일을 Base64 문자열로 변환

    // Base64 문자열과 파일 형식 정보를 JSON 형식으로 변환
    final json = {
      'file_data': base64Str,
      'file_format': Platform.isIOS ? 'aac' : 'wav',
    };
    // 직렬화
    final jsonString = Serializer.serialize(json);

    // Isolate(쓰레드와 비슷한 개념) 생성 후 파일 전송
    Isolate.spawn(sendRecordedFile, {'sendPort': receivePort.sendPort, 'fileData': jsonString});  // JSON 문자열을 전달

    // // 파일 전송 결과를 기다림
    // String recordedText = await receivePort.first;
    //
    // // 녹음이 완료된 텍스트를 처리
    // _onRecorded(recordedText);
  }


  // 웹소켓을 통해 녹음한 파일 전송
  static Future<void> sendRecordedFile(Map<String, dynamic> args) async {
    SendPort sendPort = args['sendPort'];
    String? fileData = args['fileData'];

    // 보낼 녹음 파일이 없으면 메시지 출력
    if (fileData == null) {
      print('No recorded file to send');
      return;
    }

    // 웹소켓 연결, 현재 로컬서버
    final channel = WebSocketChannel.connect(
        Uri.parse('wss://www.voiceai.co.kr:8889/client/ws/flutter'),
    );

    // stream에 데이터를 추가
    channel.sink.add(fileData);

    // 서버로부터의 응답을 받아 메인 Isolate로 전송
    channel.stream.listen((message) {
      sendPort.send(message);
    });
  }

  /// 오디오 객체 해제
  void dispose() {
    _AudioRecorder!.closeRecorder();
    _AudioRecorder = null;
  }

  // void _onRecorded(String text) {
  //   receivedText.value = List.from(receivedText.value)..add(text); // 기존 텍스트에 새 텍스트 추가
  // }
}
