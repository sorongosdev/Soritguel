import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

    // 저장에 성공하면 토스트 메시지를 띄움
    Fluttertoast.showToast(
      msg: "텍스트 저장 성공!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

// 파일을 불러와 다이얼로그로 보여주는 함수
  Future<void> loadAndShowText(BuildContext context) async {
    Directory? directory;

    // 안드로이드와 iOS에서 다르게 처리
    if (Platform.isAndroid) {
      // 안드로이드: 외부 저장소 사용
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      // iOS: 앱 문서 디렉토리 사용
      directory = await getApplicationDocumentsDirectory();
    }

    // 파일 목록을 가져옵니다.
    List<FileSystemEntity> files = directory!.listSync();

    // txt 파일 목록만 필터링
    List<FileSystemEntity> txtFiles =
        files.where((file) => file.path.endsWith('.txt')).toList();

    if (!context.mounted) return;

    // 다이얼로그를 띄워서 파일 목록을 보여줌
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('파일 목록'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: txtFiles.length,
              itemBuilder: (context, index) {
                // 파일 이름만 추출
                String fileName = txtFiles[index].path.split('/').last;
                return ListTile(
                  title: Text(fileName),
                  onTap: () async {
                    // 파일을 읽고 로그에 내용을 출력
                    String content =
                        await File(txtFiles[index].path).readAsString();
                    _controller.text = content.toString();
                    if (!context.mounted) return;
                    Navigator.of(context).pop(); // 다이얼로그를 닫음
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
