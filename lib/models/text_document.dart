// lib/models/text_document.dart
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// 텍스트 문서 모델
/// 저장된 텍스트 파일의 데이터를 정의합니다
class TextDocument extends Equatable {
  final String fileName;
  final String content;
  final DateTime createdAt;
  final String filePath;

  const TextDocument({
    required this.fileName,
    required this.content,
    required this.createdAt,
    required this.filePath,
  });

  /// 파일 경로로부터 모델 객체 생성
  factory TextDocument.fromPath(String path, String content) {
    final fileName = path.split('/').last;
    DateTime createdAt;

    // 파일명에서 타임스탬프 추출 시도 (yyyyMMdd_HHmmss.txt 형식 가정)
    try {
      final dateStr = fileName.split('.').first;
      createdAt = DateFormat('yyyyMMdd_HHmmss').parse(dateStr);
    } catch (e) {
      // 파싱 실패 시 현재 시간 사용
      createdAt = DateTime.now();
    }

    return TextDocument(
      fileName: fileName,
      content: content,
      createdAt: createdAt,
      filePath: path,
    );
  }

  /// 새 문서 생성
  factory TextDocument.create(String content, String directoryPath) {
    final now = DateTime.now();
    final formatter = DateFormat('yyyyMMdd_HHmmss');
    final fileName = '${formatter.format(now)}.txt';
    final filePath = '$directoryPath/$fileName';

    return TextDocument(
      fileName: fileName,
      content: content,
      createdAt: now,
      filePath: filePath,
    );
  }

  @override
  List<Object> get props => [fileName, content, createdAt, filePath];
}