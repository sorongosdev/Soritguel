// mic_icon.dart
import 'package:flutter/material.dart';
import 'audio_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

/// 마이크 아이콘, 녹음 시작/중지 시 아이콘이 변경되어야하므로 Stateful 사용
class MicIcon extends StatefulWidget {
  final double micTopMargin;
  final AudioRecorder audioRecorder; // AudioRecorder 추가
  final ValueNotifier<bool> isRecording; // 변경

  const MicIcon({
    Key? key,
    required this.micTopMargin,
    required this.audioRecorder, // 오디오 객체
    required this.isRecording, // 마이크 아이콘 상태 변경을 위해 녹음중인지 판단하는 변수 필요

  }) : super(key: key);

  @override
  _MicIconState createState() => _MicIconState();
}

class _MicIconState extends State<MicIcon> {
  /// 녹음중인지 관찰하고, 마이크 아이콘의 상태를 변경
  void _toggleRecording() async {
    if (widget.isRecording.value) { // 수정
      await widget.audioRecorder.stopRecording();
      widget.isRecording.value = false; // 수정
    } else {
      bool permissionGranted = await requestPermissions();
      if (permissionGranted) {
        await widget.audioRecorder.startRecording();
        widget.isRecording.value = true; // 수정
      }
    }
    setState(() {});
  }

  ///마이크 권한 요청
  Future<bool> requestPermissions() async {
    //마이크 권한 요청
    PermissionStatus status = await Permission.microphone.request();
    print('Permission status: $status');

    //권한이 있는 경우
    if(status.isGranted || status.isPermanentlyDenied){
      return Future.value(true);
    } //권한이 없는 경우
    else{
      bool goToSettings = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('마이크 권한이 필요합니다'),
            content: const Text('설정창으로 이동하시겠습니까?'),
            actions: [
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop(true); // 다이얼로그를 닫고 true를 반환
                },
              ),
              TextButton(
                child: const Text('취소'),
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
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: widget.micTopMargin),
      child: ValueListenableBuilder<bool>(
        valueListenable: widget.isRecording, // 녹음 여부 변수 관찰
        builder: (context, isRecording, child) {
          return FloatingActionButton(
            onPressed: _toggleRecording,
            backgroundColor: Colors.blue,
            child: Icon(
              isRecording ? Icons.mic_off : Icons.mic,
            ),
          );
        },
      ),
    );
  }
}
