class ZerothDefine {
  // 웹소켓 연결 주소
  static const String MY_URL_test = 'wss://www.voiceai.co.kr:8889/client/ws/flutter';
  // static const String MY_URL_test = 'ws://192.168.1.100:8080';

  static const int ZEROTH_RATE_44 = 44100; // 샘플링율

  static const int ZEROTH_MONO = 1; // 채널수

  static const double RESTING_THRESHOLD = 0.7; // 기본 음성 감지 감도. 데시벨 단위로 계산하고 있기 때문에 값이 작을수록 감도가 높음
  static const double SPEAKING_THRESHOLD = 0.7; // 말하는 중의 감지 감도. 작은 소리 감소에도 반응해야하기 때문에 높여줌

  static const double LTE_RATIO = 0.98; // ste가 업데이트될 때 이전 lte를 현재 lte에 얼마나 반영할 것인지
  static const double STE_RATIO = 0.02; // ste가 업데이트될 때 이전 lte를 현재 lte에 얼마나 반영할 것인지
}
