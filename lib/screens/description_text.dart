import 'package:flutter/material.dart';

/// 설명 텍스트, 사용법을 안내
class DescriptionText extends StatelessWidget {
  const DescriptionText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Text(
        '마이크 아이콘을 클릭한 후, 화면에 말을 하면 \n하단에 텍스트로 표시됩니다.',
        style: TextStyle(fontSize: 16.0),
        textAlign: TextAlign.center,
      ),
    );
  }
}