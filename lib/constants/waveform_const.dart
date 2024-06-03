class WaveformConst {

  ///****************************************************** 그리는 파형 관련 상수
  /// 파형의 사각형 폭
  static const double RECT_WIDTH = 7.0;

  /// 진폭을 얼마나 증폭해서 파형으로 보여줄건지
  static const double SCALE_FACTOR = 100;

  /// 파형의 사각형 사이 간격
  static const double RECT_SPACING = 5;

  ///************************************* 녹음 중지 시 서서히 감소하게 보이기 위한 상수
  /// 녹음이 중지되고 감소될 때의 감소 비율 - 값이 작을수록 빠르게 감소
  static const double FADING_SLOPE = 0.5;
  /// 녹음이 중지되고 감소될 때의 감소 상수 - 값이 클수록 빠르게 감소
  static const double FADING_CONST = 0.001;
  /// 녹음 중지시 파형이 감소되는 것을 보여줄 간격 - 값이 작을수록 프레임이 많아지고 빠르게 감소하는 것처럼 보임
  static const int MILLISEC_PER_STEP = 100;

}
