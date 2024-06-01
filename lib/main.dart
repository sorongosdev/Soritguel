///main.dart
import 'package:audio_streamer/audio_streamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/models/waveform_model.dart';
import 'package:flutter_project/src/widgets/waveform_painter.dart';
import 'package:provider/provider.dart';
import 'screens/my_app_bar.dart';
import 'screens/mic_icon.dart';
import 'screens/description_text.dart';
import 'screens/my_text_field.dart';
import 'screens/bottom_button_row.dart';
import 'src/audio_streamer.dart';
import 'models/text_size_model.dart';
import 'models/text_store_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TextSizeModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => TextStoreModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => WaveformModel(),
        )
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyWidget(),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  MyWidgetState createState() => MyWidgetState();
}

class MyWidgetState extends State<MyWidget> {
  late final mAudioStreamer audioStreamer; // audioStreamer 인스턴스 선언

  @override
  void initState() {
    super.initState();
    audioStreamer = mAudioStreamer(); // audioStreamer 초기화
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
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: MyAppBar(),
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            MicIcon(
              micTopMargin: micTopMargin,
              audioStreamer: audioStreamer, // audioStreamer 인스턴스 전달
              isRecording: audioStreamer.isRecording, // isRecording 전달
            ),
            const DescriptionText(),
            WaveformView(
              audioStreamer: audioStreamer,
              waveFormHeight: waveFormHeight,
              waveFormWidth: screenWidth,
            ),
            MyTextField(
              textFieldTopMargin: textFieldTopMargin,
              textFieldSideMargin: textFieldSideMargin,
              textFieldMaxHeight: textFieldMaxHeight,
              receivedText: audioStreamer.receivedText, // receivedText 전달
            ),
            BottomButtonRow(buttonRowSideMargin: buttonRowSideMargin)
          ],
        ),
      ),
    );
  }
}
