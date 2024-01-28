/// audio_recorder.dart
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:isolate';
import 'package:fluttertoast/fluttertoast.dart';
import 'serializer.dart';


class AudioRecorder {
  ReceivePort receivePort = ReceivePort();

  FlutterSoundRecorder? _AudioRecorder;
  bool _isRecording = false;
  String? _filePath; // 녹음한 파일 경로를 저장하기 위한 변수
  WebSocketChannel? _channel; // 웹소켓 채널

  AudioRecorder() {
    _init();
    receivePort.listen((message) { // 추가
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  Future<void> _init() async {
    _AudioRecorder = FlutterSoundRecorder();
    await _AudioRecorder!.openRecorder();
  }

  Future<void> startRecording() async {
    Directory? directory = await getExternalStorageDirectory();
    _filePath = directory!.path + '/my_record.wav'; // 변경: 녹음한 파일 경로를 저장
    await _AudioRecorder!.startRecorder(toFile: _filePath);
    _isRecording = true;
  }


  Future<void> stopRecording() async {
    await _AudioRecorder!.stopRecorder();
    _isRecording = false;

    final file = File(_filePath!);
    final jsonString = await Serializer.fileToJson(file);  // 파일을 JSON 형식으로 변환

    // Isolate(쓰레드) 생성
    Isolate.spawn(sendRecordedFile, {'sendPort': receivePort.sendPort, 'fileData': jsonString});  // JSON 문자열을 전달
  }

  // 웹소켓을 통해 녹음한 파일 전송
  static Future<void> sendRecordedFile(Map<String, dynamic> args) async {
    SendPort sendPort = args['sendPort'];
    String? fileData = args['fileData'];

    if (fileData == null) {
      print('No recorded file to send');
      return;
    }

    final channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.1.102:8080'),
    );

    // 바이너리 데이터를 문자열 형태로 변환하는 인코딩 방식
    // 64개의 출력 가능 문자 (A-Z, a-z, 0-9, +, /)와 패딩을 위한 =를 사용하여 모든 바이너리 데이터를 표현
    channel.sink.add(fileData);

    // 서버로부터의 응답을 받아 메인 Isolate로 전송
    channel.stream.listen((message) {
      sendPort.send(message);
    });
  }

  bool get isRecording => _isRecording;

  void dispose() {
    _AudioRecorder!.closeRecorder();
    _AudioRecorder = null;
  }
}
