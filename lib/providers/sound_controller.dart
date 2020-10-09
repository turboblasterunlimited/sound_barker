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

/// A native media format
/// MediaFormat: adts/aac
/// Format/Container: ADTS in an MPEG container.
///
/// Support by both ios and android
class AACMediaFormat extends NativeMediaFormat {
  /// ctor
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

  // Whilst the actual index is MediaRecorder.AudioEncoder.AAC (3)
  @override
  int get androidEncoder => 3;

  /// MediaRecorder.OutputFormat.AAC_ADTS
  @override
  int get androidFormat => 6;

  /// kAudioFormatMPEG4AAC
  @override
  int get iosFormat => 1633772320;
}

class SoundController with ChangeNotifier {
  SoundRecorder recorder = SoundRecorder();
  SoundPlayer player = SoundPlayer.noUI();

  SoundController();

  Future<void> startPlayer(String path, [Function callback, bool url]) async {
    if (player.isPlaying) {
      print("Pressing play while player is playing");
      await stopPlayer();
    }

    player.onStopped = ({wasUser: false}) {
      print("Audio Stopped test");
      callback();
    };
    url == null
        ? await player.play(Track.fromFile(path))
        : player.play(Track.fromURL(path));
  }

  Future<void> stopPlayer() async {
    if (player.isPlaying) {
      await player.stop();
    }
  }

  Future<void> record(filePath) async {
    if (File(filePath).existsSync()) File(filePath).deleteSync();

    File(filePath).createSync();
    var mediaFormat = AACMediaFormat();

    print("mediaFormat: ${mediaFormat.bitRate}, ${mediaFormat.sampleRate}");

    await recorder.record(
      Track.fromFile(
        filePath,
        mediaFormat: mediaFormat,
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
