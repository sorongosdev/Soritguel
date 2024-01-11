import 'package:flutter/material.dart';

/**마이크 아이콘*/
class MicIcon extends StatelessWidget {
  final double micTopMargin;

  const MicIcon({Key? key, required this.micTopMargin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: micTopMargin),
      child: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        child: const Icon(Icons.mic),
      ),
    );
  }
}