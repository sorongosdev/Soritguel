import 'package:flutter/material.dart';
import 'package:flutter_project/constants/tag_const.dart';

/// 오디오 버퍼가 변경될 때마다 waveform을 그려주는 클래스에 알림을 보냄
class WaveformModel with ChangeNotifier {

  double _newAmp = 0.0; // 오디오의 진폭 데이터를 저장하는 리스트

  double get newAmp => _newAmp; // ampList : _ampList에 대한 getter, 외부에서 _ampList를 읽을 수 있게 해줌

  /// 파형을 업데이트하고 데이터 변경을 알림
  void updateWaveform(double newAmp) {
    _newAmp = newAmp;
    notifyListeners();
  }

  /// 파형을 지우고 데이터 변경을 알리는 메소드
  void clearWave() {
    _newAmp=0.0;
    notifyListeners();
  }
}
