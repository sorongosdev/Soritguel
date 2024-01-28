import 'package:flutter/material.dart';
import 'my_app_bar.dart';
import 'mic_icon.dart';
import 'description_text.dart';
import 'my_text_field.dart';
import 'bottom_button_row.dart';

/// 마진 정의
/// UI를 보여줌
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyWidget(),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {  
    final micTopMargin = MediaQuery.of(context).size.height * 0.03; // 화면 높이의 3%를 마진으로 설정
    final textFieldTopMargin =
        MediaQuery.of(context).size.height * 0.03; // 화면 높이의 3%를 마진으로 설정
    final textFieldSideMargin =
        MediaQuery.of(context).size.width * 0.05; // 화면 너비의 5%를 마진으로 설정
    final textFieldMaxHeight =
        MediaQuery.of(context).size.height * 0.4; // 화면 높이의 45%를 최대 높이로 설정
    final buttonRowSideMargin =
        MediaQuery.of(context).size.width * 0.05; // 화면 너비의 5%를 마진으로 설정

    return Scaffold(
      // 앱바
      appBar: MyAppBar(),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          MicIcon(micTopMargin: micTopMargin),      // 마이크 아이콘
          DescriptionText(),                        // 설명 텍스트
          MyTextField(                              // 텍스트 필드
            textFieldTopMargin: textFieldTopMargin,
            textFieldSideMargin: textFieldSideMargin,
            textFieldMaxHeight: textFieldMaxHeight,
          ),                         // 텍스트 필드
          BottomButtonRow(buttonRowSideMargin: buttonRowSideMargin) // 하단 버튼 행
        ],
      ),
    );
  }
}