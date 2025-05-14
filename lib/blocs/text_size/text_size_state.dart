import 'package:equatable/equatable.dart';

class TextSizeState extends Equatable {
  final double size;

  const TextSizeState({required this.size});

  factory TextSizeState.initial() {
    return const TextSizeState(size: 14.0);
  }

  TextSizeState copyWith({double? size}) {
    return TextSizeState(size: size ?? this.size);
  }

  @override
  List<Object?> get props => [size];
}
