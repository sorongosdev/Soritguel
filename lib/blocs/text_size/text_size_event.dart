import 'package:equatable/equatable.dart';

abstract class TextSizeEvent extends Equatable {
  const TextSizeEvent();

  @override
  List<Object> get props => []; // 비교할 속성이 없음
}

class IncreaseTextSize extends TextSizeEvent {}

class DecreaseTextSize extends TextSizeEvent {}
