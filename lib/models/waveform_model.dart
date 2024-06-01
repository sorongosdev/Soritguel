import 'package:flutter/material.dart';

class WaveformModel with ChangeNotifier {
  List<double> _ampList = [];
  int _tick = 0;

  List<double> get ampList => _ampList;
  int get tick => _tick;

  void updateWaveform(List<double> newAmpList) {
    _ampList = newAmpList;
    _tick++;
    notifyListeners();
  }

  void clearWave() {
    _ampList.clear();
    _tick = 0;
    notifyListeners();
  }
}
