import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundController with ChangeNotifier {
  AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
  AudioPlayer backingTrack = AudioPlayer(mode: PlayerMode.LOW_LATENCY);

  dynamic stopPlayer({bool hasBackingTrack}) {
    // TEMPorary
    hasBackingTrack = true;

    if (audioPlayer.state == AudioPlayerState.PLAYING) {
      return audioPlayer.stop();
    }
    if (hasBackingTrack == true) _stopBackingTrack();
  }

  Future<String> startPlayer(path, [String backingTrackPath]) async {
    if (audioPlayer.state == AudioPlayerState.PLAYING) {
      audioPlayer.stop();
    }
    if (backingTrackPath != null) _startBackingTrack(backingTrackPath);

    return audioPlayer.play(path, isLocal: true).toString();
   
  }

  Future<String> _startBackingTrack(path) async {
    if (backingTrack.state == AudioPlayerState.PLAYING) {
      backingTrack.stop();
    }

    print("BACKING TRACK PLAYBACK STARTED...");
    return backingTrack.play(path, isLocal: true).toString();
  }

  dynamic _stopBackingTrack() {
    if (backingTrack.state == AudioPlayerState.PLAYING) {
      return backingTrack.stop();
    }
  }
}
