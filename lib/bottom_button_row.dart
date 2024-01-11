import 'package:flutter/material.dart';

/**하단 버튼 행*/
class BottomButtonRow extends StatelessWidget{
  final double buttonRowSideMargin;

  const BottomButtonRow({
    Key? key,
    required this.buttonRowSideMargin
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: buttonRowSideMargin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const Expanded(
            child: Text(
              '텍스트 크기',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('크게'),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('작게'),
            ),
          ),
        ],
      ),
    );
  }

}