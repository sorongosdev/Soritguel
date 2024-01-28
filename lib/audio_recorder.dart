/// audio_recorder.dart
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:isolate';
import 'package:fluttertoast/fluttertoast.dart';
import 'serializer.dart';
import 'package:intl/intl.dart';

class AudioRecorder {
  ReceivePort receivePort = ReceivePort();

  FlutterSoundRecorder? _AudioRecorder;
  bool _isRecording = false;
  String? _filePath; // 녹음한 파일 경로를 저장하기 위한 변수

  // 서버로부터 메시지를 받아 토스트 메시지로 출력
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

  /// 오디오 초기화
  Future<void> _init() async {
    _AudioRecorder = FlutterSoundRecorder();
    await _AudioRecorder!.openRecorder();
  }

    Future<void> startRecording() async {
      // `Android/data/{프로젝트 이름}/`
      Directory? directory = await getExternalStorageDirectory();

      // 현재 시간을 yyyyMMdd_HHmmss 형태로 포맷
      var now = DateTime.now();
      var formatter = DateFormat('yyyyMMdd_HHmmss');
      String formattedTime = formatter.format(now);

      // 녹음한 파일 경로를 저장
      _filePath = directory!.path + '/' + formattedTime + '.wav';
      await _AudioRecorder!.startRecorder(toFile: _filePath);
      _isRecording = true;
    }


  Future<void> stopRecording() async {
    await _AudioRecorder!.stopRecorder();
    _isRecording = false;

    // 파일 경로
    final file = File(_filePath!);
    final jsonString = await Serializer.fileToJson(file);  // 파일을 JSON 형식으로 변환

    // Isolate(쓰레드와 비슷한 개념) 생성 후 파일 전송
    Isolate.spawn(sendRecordedFile, {'sendPort': receivePort.sendPort, 'fileData': jsonString});  // JSON 문자열을 전달
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
        Uri.parse('ws://192.168.1.102:8080'),
    );

    // stream에 데이터를 추가
    channel.sink.add(fileData);

    // 서버로부터의 응답을 받아 메인 Isolate로 전송
    channel.stream.listen((message) {
      sendPort.send(message);
    });
  }

  /// 마이크 녹음 시작/중지 토글을 위해 필요
  bool get isRecording => _isRecording;

  /// 오디오 객체 해제
  void dispose() {
    _AudioRecorder!.closeRecorder();
    _AudioRecorder = null;
  }
}
