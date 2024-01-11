import 'package:flutter/material.dart';

/**텍스트 필드*/
class MyTextField extends StatelessWidget {
  final double textFieldTopMargin;
  final double textFieldSideMargin;
  final double textFieldMaxHeight;

  const MyTextField({
    Key? key,
    required this.textFieldTopMargin,
    required this.textFieldSideMargin,
    required this.textFieldMaxHeight
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          top: textFieldTopMargin,
          left: textFieldSideMargin,
          right: textFieldSideMargin),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5.0),
      ),
      height: textFieldMaxHeight,
      child: const SingleChildScrollView(
        child: TextField(
          maxLines: null, // 줄 바꿈에 따라 자동으로 늘어나도록 설정
          decoration: InputDecoration(
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}