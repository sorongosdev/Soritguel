// mic_icon.dart
import 'package:flutter/material.dart';
import 'audio_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

class MicIcon extends StatefulWidget {
  final double micTopMargin;

  const MicIcon({Key? key, required this.micTopMargin}) : super(key: key);

  @override
  _MicIconState createState() => _MicIconState();
}

class _MicIconState extends State<MicIcon> {
  ///오디오 객체 생성
  final AudioRecorder _AudioRecorder = AudioRecorder();

  ///녹음중일 때 버튼을 한번 더 누르면 정지
  void _toggleRecording() async {
    if (_AudioRecorder.isRecording) {
      await _AudioRecorder.stopRecording();
    } else {
      bool permissionGranted = await requestPermissions();
      if (permissionGranted) {
        await _AudioRecorder.startRecording();
      }
    }
    setState(() {});
  }

  ///마이크 권한 요청
  Future<bool> requestPermissions() async {
    //마이크 권한 요청
    PermissionStatus status = await Permission.microphone.request();

    if(status.isGranted){
      return Future.value(true);
    }
    else{
      bool goToSettings = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('마이크 권한이 필요합니다'),
            content: Text('설정창으로 이동하시겠습니까?'),
            actions: [
              TextButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop(true); // 다이얼로그를 닫고 true를 반환
                },
              ),
              TextButton(
                child: Text('취소'),
                onPressed: () {
                  Navigator.of(context).pop(false); // 다이얼로그를 닫고 false를 반환
                },
              ),
            ],
          );
        },
      ) ?? false; // 사용자가 다이얼로그 외부를 탭하여 닫는 경우를 대비해 null을 false로 처리

      // 사용자가 '확인'을 눌렀을 경우 앱 설정으로 이동
      if (goToSettings) {
        openAppSettings();
      }

      return Future.value(false);
    }
  }



  @override
  void dispose() {
    _AudioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: widget.micTopMargin),
      child: FloatingActionButton(
        onPressed: _toggleRecording,
        backgroundColor: Colors.blue,
        child: Icon(_AudioRecorder.isRecording ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}
