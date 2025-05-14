import 'package:flutter_bloc/flutter_bloc.dart';
import 'text_size_event.dart';
import 'text_size_state.dart';

class TextSizeBloc extends Bloc<TextSizeEvent, TextSizeState> {
  TextSizeBloc() : super(TextSizeState.initial()) {
    on<IncreaseTextSize>(_onIncreaseTextSize);
    on<DecreaseTextSize>(_onDecreaseTextSize);
  }

  void _onIncreaseTextSize(IncreaseTextSize event, Emitter<TextSizeState> emit) {
    emit(state.copyWith(size: state.size + 2.0));
  }

  void _onDecreaseTextSize(DecreaseTextSize event, Emitter<TextSizeState> emit) {
    final newSize = state.size - 2.0;
    // 텍스트 사이즈가 최소 8.0 이상이 되도록 제한
    if (newSize >= 8.0) {
      emit(state.copyWith(size: newSize));
    }
  }
}