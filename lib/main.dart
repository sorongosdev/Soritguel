///main.dart
import 'package:flutter/material.dart';
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
          create: (context) =>  TextSizeModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => TextStoreModel(),
        ),
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
    final micTopMargin = MediaQuery.of(context).size.height * 0.03;
    final textFieldTopMargin = MediaQuery.of(context).size.height * 0.03;
    final textFieldSideMargin = MediaQuery.of(context).size.width * 0.05;
    final textFieldMaxHeight = MediaQuery.of(context).size.height * 0.4;
    final buttonRowSideMargin = MediaQuery.of(context).size.width * 0.05;

    return Scaffold(
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
          DescriptionText(),
          MyTextField(
            textFieldTopMargin: textFieldTopMargin,
            textFieldSideMargin: textFieldSideMargin,
            textFieldMaxHeight: textFieldMaxHeight,
            receivedText: audioStreamer.receivedText, // receivedText 전달
          ),
          BottomButtonRow(buttonRowSideMargin: buttonRowSideMargin)
        ],
      ),
    );
  }
}
