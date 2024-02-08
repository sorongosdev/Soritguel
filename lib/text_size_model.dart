/// text_size_model.dart
import 'package:flutter/foundation.dart';

/// 텍스트필드의 텍스트 사이즈를 조절하기 위한 모델
class TextSizeModel with ChangeNotifier {
  // 기본 텍스트 사이즈
  double _textSize = 14.0;

  double get textSize => _textSize;

  /// 텍스트 사이즈 증가
  void increaseTextSize() {
    _textSize += 2.0;
    notifyListeners();
  }

  /// 텍스트 사이즈 감소
  void decreaseTextSize() {
    _textSize -= 2.0;
    notifyListeners();
  }
}
