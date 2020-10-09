// import 'package:flutter/material.dart';
// // import 'package:flutter_sound/flutter_sound.dart';

// // import 'package:flutter_sound_lite/flutter_sound.dart';
// import'package:sounds/sounds.dart';

// class SoundController with ChangeNotifier {
//   FlutterSoundRecorder recorder = FlutterSoundRecorder();
//   FlutterSoundPlayer player = FlutterSoundPlayer();
//   Function lastCallback;

//   SoundController();

//   Future<void> startPlayer(String path, [Function callback]) async {
//     if (player.isPlaying) {
//       stopPlayer();
//       lastCallback();
//     }
//     print("audio path: $path");
//     await player.openAudioSession(
//         focus: AudioFocus.requestFocusTransient,
//         category: SessionCategory.playback,
//         mode: SessionMode.modeDefault);
//     await player.startPlayer(fromURI: path, whenFinished: callback);
//     lastCallback = callback;
//   }

//   void stopPlayer() {
//     if (player.isPlaying) {
//       // player.stopPlayer();
//       player.closeAudioSession();
//     }
//   }

//   Future<void> record(filePath) async {
//     await recorder.openAudioSession(
//         focus: AudioFocus.requestFocusTransient,
//         category: SessionCategory.record,
//         mode: SessionMode.modeDefault);

//     await recorder.startRecorder(
//         toFile: filePath, sampleRate: 44100, bitRate: 192000);
//   }

//   Future<void> stopRecording() async {
//     // recorder.stopRecorder();
//     await recorder.closeAudioSession();
//   }
// }

import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:flutter_sound/flutter_sound.dart';

// import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:sounds/sounds.dart';
import 'package:sounds/src/quality.dart';

class SoundController with ChangeNotifier {
  SoundRecorder recorder = SoundRecorder();
  SoundPlayer player = SoundPlayer.noUI();
  Function lastCallback;

  SoundController();

  Future<void> startPlayer(String path, [Function callback, bool url]) async {
    if (player.isPlaying) {
      print("Pressing play while player is playing");
      await stopPlayer();
    }

    player.onStopped = ({wasUser: true}) {
      print("Audio Stopped test");
      callback();
    };
    url == null ? await player.play(Track.fromFile(path)) : player.play(Track.fromURL(path));
  }

  Future<void> stopPlayer() async {
    if (player.isPlaying) {
      print("Pressing stop while player is playing");
      await player.stop(wasUser: true);
    }
  }

  Future<void> record(filePath) async {
    if (File(filePath).existsSync()) {
      print("Filepath exists.");
      File(filePath).deleteSync();
    } else
      print("Filepath does not exist.");
    File(filePath).createSync();

    if (File(filePath).existsSync()) print("Filepath now exists.");

    await recorder.record(
        Track.fromFile(filePath, mediaFormat: AdtsAacMediaFormat()),
        quality: Quality.high);
  }

  Future<void> stopRecording() async {
    // recorder.stopRecorder();
    if (recorder.isRecording) {
      recorder.stop();
    }
  }
}
