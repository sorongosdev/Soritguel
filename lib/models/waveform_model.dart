import 'package:flutter/material.dart';

/// 오디오 버퍼가 변경될 때마다 waveform을 그려주는 클래스에 알림을 보냄
class WaveformModel with ChangeNotifier {

  List<double> _ampList = []; // 오디오의 진폭 데이터를 저장하는 리스트
  int _tick = 0; // 오디오 데이터가 업데이트될 때마다 증가하는 카운터

  List<double> get ampList => _ampList; // ampList : _ampList에 대한 getter, 외부에서 _ampList를 읽을 수 있게 해줌
  int get tick => _tick; // tick : _tick에 대한 getter, 외부에서 _tick을 읽을 수 있게 해줌

  /// 새로운 진폭 리스트를 받아 현재 리스트를 업데이트,
  /// tick 카운터를 1 증가시킨 후, 데이터 변경을 알리는 메소드
  void updateWaveform(List<double> newAmpList) {
    _ampList = newAmpList;
    _tick++;
    notifyListeners();
  }

  /// 진폭 리스트를 비우고 tick 카운터를 0으로 초기화한 후,
  /// 데이터 변경을 알리는 메소드
  void clearWave() {
    _ampList.clear();
    _tick = 0;
    notifyListeners();
  }
}
