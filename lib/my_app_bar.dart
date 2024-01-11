import 'package:flutter/material.dart';

/**앱바*/
class MyAppBar extends AppBar {
  MyAppBar() : super( // MyAppBar 클래스 초기화 후 인수 전달
    title: Text('STT'),
    centerTitle: true,
    backgroundColor: Colors.blue,
    actions: <Widget>[
      PopupMenuButton<String>(
        icon: Icon(Icons.more_vert),
        itemBuilder: (BuildContext context) =>
        <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: '새로시작',
            child: Text('새로시작'),
          ),
          const PopupMenuItem<String>(
            value: '저장',
            child: Text('저장'),
          ),
          const PopupMenuItem<String>(
            value: '불러오기',
            child: Text('불러오기'),
          ),
          const PopupMenuItem<String>(
            value: '공유하기',
            child: Text('공유하기'),
          ),
        ],
      ),
    ],
  );
}