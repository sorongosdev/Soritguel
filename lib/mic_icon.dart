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
  final AudioRecorder _AudioRecorder = AudioRecorder();

  ///녹음중일 때 버튼을 한번 더 누르면 정지
  void _toggleRecording() async {
    if (_AudioRecorder.isRecording) {
      await _AudioRecorder.stopRecording();
    } else {
      bool permissionGranted = await requestPermissions();
      if (permissionGranted) {
        await _AudioRecorder.startRecording();
      } else {
        // Handle the case where the user did not grant the permission.
      }
    }
    setState(() {});
  }



  ///마이크 권한 요청
  Future<bool> requestPermissions() async {
    //마이크 권한 요청 다이얼로그
    PermissionStatus status = await Permission.microphone.request();

    if(status.isGranted){
      return Future.value(true);
    }
    else{
      //Permission은 최초 거부를 누르게 되면 Permission 요청을 보내지 않음
      //따라서 openAppSettings(); 함수를 이용해 별도 사용자가 직접 권한을 켜주게 함
      openAppSettings();
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
