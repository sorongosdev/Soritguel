// lib/repositories/text_storage_repository.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/text_document.dart';

class TextStorageRepository {
  // 텍스트 저장
  Future<TextDocument> saveText(String text) async {
    Directory? directory;

    // 안드로이드와 iOS에서 다르게 처리
    if (Platform.isAndroid) {
      // 안드로이드: 외부 저장소 사용
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      // iOS: 앱 문서 디렉토리 사용
      directory = await getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    // 새 TextDocument 모델 생성
    final textDocument = TextDocument.create(text, directory!.path);
    
    // 파일 저장
    final file = File(textDocument.filePath);
    await file.writeAsString(text);
    
    return textDocument;
  }

  // 텍스트 파일 목록 불러오기 및 다이얼로그 표시
  Future<void> showTextFilesDialog(BuildContext context, TextEditingController controller) async {
    // 텍스트 파일 목록 가져오기
    List<TextDocument> documents = await getTextDocuments();

    if (!context.mounted) return;

    // 다이얼로그를 띄워서 파일 목록 표시
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('파일 목록'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final document = documents[index];
                return ListTile(
                  title: Text(document.fileName),
                  subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(document.createdAt)),
                  onTap: () async {
                    controller.text = document.content;
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

  // 텍스트 문서 목록 가져오기
  Future<List<TextDocument>> getTextDocuments() async {
    Directory? directory;

    // 안드로이드와 iOS에서 다르게 처리
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    // 파일 목록 가져오기
    List<FileSystemEntity> files = directory!.listSync();

    // txt 파일 목록만 필터링
    List<FileSystemEntity> txtFiles =
        files.where((file) => file.path.endsWith('.txt')).toList();
    
    // 각 파일의 내용을 읽어 TextDocument 객체로 변환
    List<TextDocument> documents = [];
    for (var file in txtFiles) {
      String content = await File(file.path).readAsString();
      documents.add(TextDocument.fromPath(file.path, content));
    }
    
    // 날짜 기준으로 정렬 (최신순)
    documents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return documents;
  }

  // 특정 파일 내용 불러오기
  Future<TextDocument> getTextDocument(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    return TextDocument.fromPath(filePath, content);
  }
}