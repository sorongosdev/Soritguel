import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'text_size_model.dart';

/// 텍스트필드, 상태가 변경되기 때문에 stateful 사용
class MyTextField extends StatefulWidget {
  final double textFieldTopMargin;
  final double textFieldSideMargin;
  final double textFieldMaxHeight;
  final ValueNotifier<List<String>> receivedText; // 타입 변경

  const MyTextField({
    Key? key,
    required this.textFieldTopMargin,
    required this.textFieldSideMargin,
    required this.textFieldMaxHeight,
    required this.receivedText // 서버로 받은 텍스트
  }) : super(key: key);

  @override
  MyTextFieldState createState() => MyTextFieldState();
}

/// StatefulWidget의 상태를 관리하는 데 사용되는 state 클래스
class MyTextFieldState extends State<MyTextField> {
  late TextEditingController _controller;
  double _textSize = 14.0; // 텍스트 크기 변수 추가

  @override
  void initState() {
    super.initState();
    // 텍스트를 변경하는 컨트롤러 변수 설정
    _controller = TextEditingController(text: widget.receivedText.value.join('\n'));
    // 텍스트를 업데이트하는 리스너 추가
    widget.receivedText.addListener(_updateText);
  }

  @override
  void dispose() {
    // 텍스트 리스너 해제
    widget.receivedText.removeListener(_updateText);
    // 컨트롤러 해제
    _controller.dispose();
    super.dispose();
  }

  /// 텍스트를 업데이트하는 함수
  void _updateText() {
    List<String> lines = widget.receivedText.value; // 텍스트 리스트 받아오기
    String text = lines.join("\n"); // 줄 바꿈 문자로 각 줄을 합치기
    _controller.text = text; // 텍스트 필드 업데이트
  }

  // 텍스트 크기 증가시키는 함수
  void increaseTextSize() {
    setState(() {
      _textSize += 2.0;
    });
  }

  // 텍스트 크기 감소시키는 함수
  void decreaseTextSize() {
    setState(() {
      _textSize -= 2.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          top: widget.textFieldTopMargin,
          left: widget.textFieldSideMargin,
          right: widget.textFieldSideMargin),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5.0),
      ),
      height: widget.textFieldMaxHeight,
      child: SingleChildScrollView(
        child: Consumer<TextSizeModel>( // Consumer를 사용하여 TextSizeModel에 접근
          builder: (context, textSizeModel, child) {
            return TextField(
              maxLines: null,
              controller: _controller,
              style: TextStyle(fontSize: textSizeModel.textSize), // 텍스트 크기를 TextSizeModel에서 가져옴
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            );
          },
        ),
      ),
    );
  }


}
