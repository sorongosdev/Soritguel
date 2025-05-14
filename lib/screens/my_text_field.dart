import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/audio/audio_bloc.dart';
import '../blocs/audio/audio_state.dart';
import '../blocs/text_size/text_size_bloc.dart';
import '../blocs/text_size/text_size_state.dart';
import '../blocs/text_store/text_store_bloc.dart';
import '../blocs/text_store/text_store_event.dart';

/// 텍스트필드, 받은 텍스트를 표시하고 편집 가능
class MyTextField extends StatefulWidget {
  final double textFieldTopMargin;
  final double textFieldSideMargin;
  final double textFieldMaxHeight;

  const MyTextField({
    Key? key,
    required this.textFieldTopMargin,
    required this.textFieldSideMargin,
    required this.textFieldMaxHeight,
  }) : super(key: key);

  @override
  MyTextFieldState createState() => MyTextFieldState();
}

class MyTextFieldState extends State<MyTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // 텍스트 컨트롤러 초기화
    _controller = TextEditingController();
    
    // TextStoreBloc에 컨트롤러 등록
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TextStoreBloc>().add(InitializeController(_controller));
    });
  }

  @override
  void dispose() {
    // 컨트롤러 해제
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AudioBloc에서 받은 텍스트 리스너
    return BlocListener<AudioBloc, AudioState>(
      listenWhen: (previous, current) => previous.textLines != current.textLines,
      listener: (context, state) {
        if (state.textLines.isNotEmpty) {
          // 텍스트가 들어오면 추가
          _updateText(state.textLines);
        }
      },
      child: Container(
        margin: EdgeInsets.only(
          top: widget.textFieldTopMargin,
          left: widget.textFieldSideMargin,
          right: widget.textFieldSideMargin,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        height: widget.textFieldMaxHeight,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: BlocBuilder<TextSizeBloc, TextSizeState>(
                builder: (context, state) {
                  return TextField(
                    maxLines: null,
                    controller: _controller,
                    style: TextStyle(fontSize: state.size),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(10.0),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: IconButton(
                icon: const Icon(Icons.delete_forever),
                onPressed: () {
                  _controller.clear();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 텍스트를 업데이트하는 함수
  void _updateText(List<String> texts) {
    String text = texts.join("\n"); // 줄 바꿈 문자로 각 줄을 합치기
    
    if (_controller.text.isEmpty) {
      _controller.text = text;
    } else {
      _controller.text = '${_controller.text} $text'; // 텍스트 필드 업데이트
    }
  }
}