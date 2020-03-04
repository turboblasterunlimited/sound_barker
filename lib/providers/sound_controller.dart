import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

class SoundController with ChangeNotifier {
  FlutterSound flutterSound = FlutterSound();

  dynamic stopPlayer() {
    if (t_AUDIO_STATE.IS_PLAYING == flutterSound.audioState) {
      return flutterSound.stopPlayer();
    }
  }

  Future<String> startPlayer(path) {
    if (t_AUDIO_STATE.IS_PLAYING == flutterSound.audioState) {
      flutterSound.stopPlayer();
    }
    return flutterSound.startPlayer(path);
  }
}
