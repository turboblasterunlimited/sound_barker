import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';

class SoundController with ChangeNotifier {
  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  FlutterSoundPlayer player = FlutterSoundPlayer();
  Function lastCallback;

  SoundController();

  Future<void> startPlayer(String path, [Function callback]) async {
    if (player.isPlaying) {
      stopPlayer();
      lastCallback();
    }
    print("audio path: $path");
    player.openAudioSession(
        focus: AudioFocus.requestFocusTransient,
        category: SessionCategory.playback,
        mode: SessionMode.modeDefault);
    player.startPlayer(fromURI: path, whenFinished: callback);
    lastCallback = callback;
  }

  void stopPlayer() {
    if (player.isPlaying) {
      // player.stopPlayer();
      player.closeAudioSession();
    }
  }

  Future<void> record(filePath) {
    recorder.openAudioSession(
        focus: AudioFocus.requestFocusTransient,
        category: SessionCategory.record,
        mode: SessionMode.modeDefault);

    recorder.startRecorder(
        toFile: filePath, sampleRate: 44100, bitRate: 192000);
  }

  void stopRecording() {
    // recorder.stopRecorder();
    recorder.closeAudioSession();
  }
}
