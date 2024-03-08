import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/text_size_model.dart';

///하단 버튼 행
class BottomButtonRow extends StatefulWidget {
  final double buttonRowSideMargin;

  const BottomButtonRow({
    Key? key,
    required this.buttonRowSideMargin,
  }) : super(key: key);

  @override
  _BottomButtonRowState createState() => _BottomButtonRowState();
}

class _BottomButtonRowState extends State<BottomButtonRow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: widget.buttonRowSideMargin),
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
              onPressed: () {
                Provider.of<TextSizeModel>(context, listen: false).increaseTextSize(); // 텍스트 크기 증가
              },
              child: const Text('크게'),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Provider.of<TextSizeModel>(context, listen: false).decreaseTextSize(); // 텍스트 크기 감소
              },
              child: const Text('작게'),
            ),
          ),
        ],
      ),
    );
  }
}

