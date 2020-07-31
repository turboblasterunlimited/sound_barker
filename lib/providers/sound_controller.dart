import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';

class SoundController with ChangeNotifier {
  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  FlutterSoundPlayer player = FlutterSoundPlayer();
  Function lastCallback;

  SoundController() {
    player.openAudioSession(
        focus: AudioFocus.requestFocusTransient,
        category: SessionCategory.playback,
        mode: SessionMode.modeDefault);
    recorder.openAudioSession(
        focus: AudioFocus.requestFocusTransient,
        category: SessionCategory.record,
        mode: SessionMode.modeDefault);
  }

  void stopPlayer() {
    if (player.isPlaying) {
      player.stopPlayer();
    }
  }

  Future<void> startPlayer(String path, [Function callback]) async {
    if (player.isPlaying) {
      stopPlayer();
      lastCallback();
    }
    print("audio path: $path");
    player.startPlayer(fromURI: path, whenFinished: callback);
    lastCallback = callback;
  }
}
