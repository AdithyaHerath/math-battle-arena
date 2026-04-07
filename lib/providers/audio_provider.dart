import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _musicPlayer = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  AudioProvider() {
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playBackgroundMusic() async {
    if (!_isPlaying) {
      // audio files in assets/audio/ are loaded using 'audio/filename.mp3' or just 'filename.mp3' 
      // wait, audioplayers typically defaults to assets/ if no prefix or if asset prefix is given.
      // With AssetSource it implies the path is relative to assets/
      await _musicPlayer.play(AssetSource('audio/hollow.mp3'), volume: 0.5);
      _isPlaying = true;
      notifyListeners();
    }
  }

  Future<void> pauseMusic() async {
    if (_isPlaying) {
      await _musicPlayer.pause();
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> stopMusic() async {
    if (_isPlaying) {
      await _musicPlayer.stop();
      _isPlaying = false;
      notifyListeners();
    }
  }

  void toggleMusic() {
    if (_isPlaying) {
      pauseMusic();
    } else {
      playBackgroundMusic();
    }
  }

  @override
  void dispose() {
    _musicPlayer.dispose();
    super.dispose();
  }
}
