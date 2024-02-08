import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class TextStoreModel with ChangeNotifier {

  // 텍스트필드의 텍스트를 읽어오기 위한 컨트롤러
  late TextEditingController _controller;

  /// 텍스트필드의 텍스트를 읽어오기 위한 컨트롤러 지정
  void setController(TextEditingController controller) {
    _controller = controller;
    notifyListeners();
  }

  /// 앱바에서 저장버튼을 누르면 텍스트필드의 텍스트를 텍스트파일에 저장
  Future<void> saveText() async {

    Directory? directory;
    String text = _controller.text;

    // 안드로이드와 iOS에서 다르게 처리
    if (Platform.isAndroid) {
      // 안드로이드: 외부 저장소 사용
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      // iOS: 앱 문서 디렉토리 사용
      directory = await getApplicationDocumentsDirectory();
    }

    // 현재 시간을 yyyyMMdd_HHmmss 형태로 포맷
    var now = DateTime.now();
    var formatter = DateFormat('yyyyMMdd_HHmmss');
    String formattedTime = formatter.format(now);

    // filePath에 txt  저장
    final filePath = '${directory!.path}/$formattedTime.txt';
    final file = File(filePath);
    await file.writeAsString(text);
  }
}
