import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/text_store/text_store_bloc.dart';
import '../blocs/text_store/text_store_event.dart';
import '../blocs/waveform/waveform_bloc.dart';
import '../blocs/waveform/waveform_event.dart';

/// 앱바 및 팝업 메뉴 구현
class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // Scaffold에서 필요

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('STT'),
      centerTitle: true,
      backgroundColor: Colors.blue,
      actions: <Widget>[
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert), // 더보기 아이콘
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: '새로시작',
              child: const Text('새로시작'),
              onTap: () {
                // 텍스트와 파형 초기화
                context.read<TextStoreBloc>().add(FreshStart());
                context.read<WaveformBloc>().add(ClearWaveform());
              },
            ),
            PopupMenuItem<String>(
              value: '저장',
              child: const Text('저장'),
              onTap: () {
                // 텍스트 저장
                context.read<TextStoreBloc>().add(SaveText());
              },
            ),
            PopupMenuItem<String>(
              value: '불러오기',
              child: const Text('불러오기'),
              onTap: () {
                // 텍스트 불러오기 다이얼로그 표시
                context.read<TextStoreBloc>().add(LoadText(context));
              },
            ),
            PopupMenuItem<String>(
              value: '공유하기',
              child: const Text('공유하기'),
              onTap: () {
                // 텍스트 공유
                context.read<TextStoreBloc>().add(ShareText());
              },
            ),
          ],
        ),
      ],
    );
  }
}