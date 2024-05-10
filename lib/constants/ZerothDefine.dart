class ZerothDefine {
  // 웹소켓 연결 주소
  static const String MY_URL_test = 'wss://www.voiceai.co.kr:8889/client/ws/flutter';
  // static const String MY_URL_test = 'wss://121.139.224.34:8889';
  // static const String MY_URL_test = 'ws://192.168.1.101:8080';

  static const int ZEROTH_RATE_44 = 44100; // 샘플링율

  static const int ZEROTH_MONO = 1; // 채널수

  static const double SPEAKING_THRESHOLD = -56; // 문장 감지 기준 데시벨
  static const double BUFFER_CUT_RATIO = 0.95; // 단어 감지 감도 계수
}
