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
import 'package:sounds/sounds.dart';
import 'package:sounds/src/quality.dart';

class AACMediaFormat extends NativeMediaFormat {
  const AACMediaFormat({
    int sampleRate = 44100,
    int numChannels = 1,
    int bitRate = 192000,
  }) : super.detail(
          name: 'adts/aac',
          sampleRate: 44100,
          numChannels: 1,
          bitRate: 192000,
        );

  @override
  String get extension => 'aac';

  @override
  int get androidEncoder => 3;
  @override
  int get androidFormat => 6;
  @override
  int get iosFormat => 1633772320;
}

class SoundController with ChangeNotifier {
  SoundRecorder recorder = SoundRecorder();
  SoundPlayer player = SoundPlayer.noUI();
  Function lastCallback;

  SoundController();

  Future<void> startPlayer(String path,
      {Function stopCallback,
      Function startAnimationCallback,
      bool url = false,
      bool asset = false}) async {
    if (player.isPlaying) {
      lastCallback();
      await stopPlayer();
    }

    // is annoyingly only triggered when audio playback completes, hence 'lastCallback' implementation
    player.onStopped = ({wasUser: true}) {
      stopCallback();
    };

    lastCallback = stopCallback;
    Track track;
    if (url)
      track = Track.fromURL(path);
    else if (asset)
      track = Track.fromAsset(path);
    else
      track = Track.fromFile(path);
    await player.play(track);
  }

  Future<void> stopPlayer() async {
    if (player.isPlaying) {
      print("tapping STOP");
      await player.stop(wasUser: false);
    }
  }

  Future<void> record(filePath) async {
    if (File(filePath).existsSync()) File(filePath).deleteSync();

    File(filePath).createSync();

    await recorder.record(
      Track.fromFile(
        filePath,
        mediaFormat: AACMediaFormat(),
      ),
      quality: Quality.high,
    );
  }

  Future<void> stopRecording() async {
    if (recorder.isRecording) {
      recorder.stop();
    }
  }
}
