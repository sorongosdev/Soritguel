import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/audio/audio_bloc.dart';
import 'blocs/audio/audio_event.dart';
import 'blocs/audio/audio_state.dart';
import 'blocs/text_size/text_size_bloc.dart';
import 'blocs/text_store/text_store_bloc.dart';
import 'blocs/waveform/waveform_bloc.dart';
import 'blocs/waveform/waveform_event.dart';
import 'repositories/audio_repository.dart';
import 'repositories/text_storage_repository.dart';
import 'screens/my_app_bar.dart';
import 'screens/mic_icon.dart';
import 'screens/description_text.dart';
import 'screens/my_text_field.dart';
import 'screens/bottom_button_row.dart';
import 'widgets/waveform_painter.dart';

// BlocObserver 추가
class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('🔵 ${bloc.runtimeType} Event: $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('🔄 ${bloc.runtimeType} Transition: $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('❌ ${bloc.runtimeType} Error: $error');
    super.onError(bloc, error, stackTrace);
  }
}

void main() {
  // BlocObserver 설정
  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AudioBloc>(
          create: (context) => AudioBloc(
            repository: AudioRepository(),
          ),
        ),
        BlocProvider<TextSizeBloc>(
          create: (context) => TextSizeBloc(),
        ),
        BlocProvider<TextStoreBloc>(
          create: (context) => TextStoreBloc(
            repository: TextStorageRepository(),
          ),
        ),
        BlocProvider<WaveformBloc>(
          create: (context) => WaveformBloc(),
        ),
      ],
      child: const MaterialApp(
        home: MyWidget(),
      ),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  MyWidgetState createState() => MyWidgetState();
}

class MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    
    // 오디오 BLoC과 파형 BLoC 간의 연결 설정
    // 오디오 진폭이 변경될 때 파형 업데이트
    context.read<AudioBloc>().stream.listen((state) {
      context.read<WaveformBloc>().add(UpdateWaveform(state.amplitude));
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final micTopMargin = screenHeight * 0.03;
    final textFieldTopMargin = screenHeight * 0.03;
    final textFieldSideMargin = screenWidth * 0.05;
    final textFieldMaxHeight = screenHeight * 0.4;
    final buttonRowSideMargin = screenWidth * 0.05;
    final waveFormHeight = screenHeight * 0.1;

    return GestureDetector(
      onTap: () {
        // 현재 포커스를 제거하여 키보드를 숨김
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: const MyAppBar(),
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            MicIcon(
              micTopMargin: micTopMargin,
            ),
            const DescriptionText(),
            WaveformView(
              waveFormHeight: waveFormHeight,
              waveFormWidth: screenWidth,
            ),
            MyTextField(
              textFieldTopMargin: textFieldTopMargin,
              textFieldSideMargin: textFieldSideMargin,
              textFieldMaxHeight: textFieldMaxHeight,
            ),
            BottomButtonRow(buttonRowSideMargin: buttonRowSideMargin)
          ],
        ),
      ),
    );
  }
}