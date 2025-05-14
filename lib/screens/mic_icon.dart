// lib/screens/mic_icon.dart 파일을 다음과 같이 완전히 수정하세요

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/audio/audio_bloc.dart';
import '../blocs/audio/audio_event.dart';
import '../blocs/audio/audio_state.dart';
import 'package:permission_handler/permission_handler.dart';

/// 마이크 아이콘, 녹음 시작/중지를 담당
class MicIcon extends StatefulWidget {
  final double micTopMargin;

  const MicIcon({
    Key? key,
    required this.micTopMargin,
  }) : super(key: key);

  @override
  State<MicIcon> createState() => _MicIconState();
}

class _MicIconState extends State<MicIcon> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // 앱 상태 변화 감지를 위한 옵저버 등록
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // 옵저버 해제
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 앱 상태 변화 감지
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final audioBloc = context.read<AudioBloc>();
    // 앱이 백그라운드로 전환되거나 비활성화될 때
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive || 
        state == AppLifecycleState.detached) {
      // 녹음 중이면 녹음 중지
      if (audioBloc.state.isRecording) {
        audioBloc.add(StopRecording());
      }
    }
  }

  /// 녹음 시작/중지 토글
  Future<void> _toggleRecording(BuildContext context, bool isRecording) async {
    final audioBloc = context.read<AudioBloc>();

    if (isRecording) {
      // 녹음 중이면 중지
      audioBloc.add(StopRecording());
    } else {
      // 녹음 중이 아니면 권한 확인 후 시작
      bool permissionGranted = await _requestPermissions(context);
      if (permissionGranted) {
        audioBloc.add(StartRecording());
      }
    }
  }

  /// 마이크 권한 요청
  Future<bool> _requestPermissions(BuildContext context) async {
    // 마이크 권한 요청
    PermissionStatus status = await Permission.microphone.request();

    // 권한이 있는 경우
    if (status.isGranted) {
      return true;
    }
    // 권한이 없는 경우
    else {
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
          ) ??
          false; // 사용자가 다이얼로그 외부를 탭하여 닫는 경우를 대비해 null을 false로 처리

      // 사용자가 '확인'을 눌렀을 경우 앱 설정으로 이동
      if (goToSettings) {
        openAppSettings();
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: widget.micTopMargin),
      child: BlocBuilder<AudioBloc, AudioState>(
        // isRecording과 status 상태가 변경될 때 위젯을 다시 빌드
        buildWhen: (previous, current) =>
            previous.isRecording != current.isRecording || 
            previous.status != current.status,
        builder: (context, state) {
          print('MicIcon rebuilding with isRecording: ${state.isRecording}, status: ${state.status}');
          return FloatingActionButton(
            onPressed: () => _toggleRecording(context, state.isRecording),
            backgroundColor: Colors.blue,
            child: Icon(
              state.isRecording ? Icons.mic_off : Icons.mic,
              key: ValueKey<bool>(state.isRecording),
            ),
          );
        },
      ),
    );
  }
}