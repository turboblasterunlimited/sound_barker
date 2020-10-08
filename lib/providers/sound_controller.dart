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
    await player.openAudioSession(
        focus: AudioFocus.requestFocusTransient,
        category: SessionCategory.playback,
        mode: SessionMode.modeDefault);
    await player.startPlayer(fromURI: path, whenFinished: callback);
    lastCallback = callback;
  }

  void stopPlayer() {
    if (player.isPlaying) {
      // player.stopPlayer();
      player.closeAudioSession();
    }
  }

  Future<void> record(filePath) async {
    await recorder.openAudioSession(
        focus: AudioFocus.requestFocusTransient,
        category: SessionCategory.record,
        mode: SessionMode.modeDefault);

    await recorder.startRecorder(
        toFile: filePath, sampleRate: 44100, bitRate: 192000);
  }

  Future<void> stopRecording() async {
    // recorder.stopRecorder();
    await recorder.closeAudioSession();
  }
}
