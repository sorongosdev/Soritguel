import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_text_field.dart';
import 'text_store_model.dart'; // TextModel을 import 해야 합니다.

class MyAppBar extends StatelessWidget implements PreferredSizeWidget{
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // main의 Scaffold에서 리턴값으로 필요

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('STT'),
      centerTitle: true,
      backgroundColor: Colors.blue,
      actions: <Widget>[
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert), // 더보기 아이콘
          itemBuilder: (BuildContext context) =>
          <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: '새로시작',
              child: Text('새로시작'),
            ),
            PopupMenuItem<String>(
              value: '저장',
              child: Text('저장'),
              onTap: () {
                Provider.of<TextStoreModel>(context, listen: false).saveText();
                // Navigator.pop(context); // 팝업 메뉴를 자동으로 닫음
              },
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
}
