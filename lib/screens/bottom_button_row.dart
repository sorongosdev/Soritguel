import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/text_size/text_size_bloc.dart';
import '../blocs/text_size/text_size_event.dart';
import '../blocs/text_size/text_size_state.dart';

/// 하단 버튼 행, 텍스트 크기 조절 버튼을 포함
class BottomButtonRow extends StatelessWidget {
  final double buttonRowSideMargin;

  const BottomButtonRow({
    Key? key,
    required this.buttonRowSideMargin,
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
            child: BlocBuilder<TextSizeBloc, TextSizeState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: () {
                    context.read<TextSizeBloc>().add(IncreaseTextSize());
                  },
                  child: const Text('크게'),
                );
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<TextSizeBloc, TextSizeState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: () {
                    context.read<TextSizeBloc>().add(DecreaseTextSize());
                  },
                  child: const Text('작게'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}