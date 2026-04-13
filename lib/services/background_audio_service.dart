import 'package:audioplayers/audioplayers.dart';

class BackgroundAudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;

  static Future<void> playMenuMusic() async {
    if (_isPlaying) return;

    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('sounds/menu_bgm.mp3'), volume: 0.4);
      _isPlaying = true;
    } catch (_) {
      // ignore missing asset or playback issues during development
    }
  }

  static Future<void> stopMenuMusic() async {
    if (!_isPlaying) return;

    try {
      await _player.stop();
    } catch (_) {
      // ignore stop errors
    }

    _isPlaying = false;
  }

  static Future<void> updateMenuMusic(bool enabled) async {
    if (enabled) {
      await playMenuMusic();
    } else {
      await stopMenuMusic();
    }
  }
}
