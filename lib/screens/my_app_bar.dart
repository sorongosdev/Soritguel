import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/text_store_model.dart';
import '../models/waveform_model.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight); // main의 Scaffold에서 리턴값으로 필요

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
                Provider.of<TextStoreModel>(context, listen: false).freshStart();
                Provider.of<WaveformModel>(context, listen: false).clearWave();
                // Navigator.pop(context); // 팝업 메뉴를 자동으로 닫음
              },
            ),
            PopupMenuItem<String>(
              value: '저장',
              child: const Text('저장'),
              onTap: () {
                Provider.of<TextStoreModel>(context, listen: false).saveText();
              },
            ),
            PopupMenuItem<String>(
              value: '불러오기',
              child: const Text('불러오기'),
              onTap: () {
                Provider.of<TextStoreModel>(context, listen: false)
                    .loadAndShowText(context);
              },
            ),
            PopupMenuItem<String>(
              value: '공유하기',
              child: const Text('공유하기'),
              onTap: () {
                Provider.of<TextStoreModel>(context,listen: false).shareText();
              },
            ),
          ],
        ),
      ],
    );
  }
}
