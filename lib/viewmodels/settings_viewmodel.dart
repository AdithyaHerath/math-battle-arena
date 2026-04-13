import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  bool _isMusicEnabled = true;
  bool _isDarkTheme = false;

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isDarkTheme => _isDarkTheme;

  void toggleMusic(bool enabled) {
    _isMusicEnabled = enabled;
    notifyListeners();
  }

  void setDarkTheme(bool enabled) {
    _isDarkTheme = enabled;
    notifyListeners();
  }
}
