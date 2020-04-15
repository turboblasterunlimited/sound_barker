import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundController with ChangeNotifier {
  AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
  AudioPlayer backingTrack = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);

  void stopPlayer([bool hasBackingTrack]) {
    print("has backing track: $hasBackingTrack");

    if (audioPlayer.state == AudioPlayerState.PLAYING) {
      audioPlayer.stop();
    }
    if (hasBackingTrack == true) _stopBackingTrack();
  }

  Future<int> startPlayer(path, [String backingTrackPath]) async {
    if (audioPlayer.state == AudioPlayerState.PLAYING) {
      stopPlayer(backingTrackPath != null);
    }
    if (backingTrackPath != null) _startBackingTrack(backingTrackPath);


    // audioPlayer.monitorNotificationStateChanges();
    audioPlayer.play(path, isLocal: true).toString();
    return audioPlayer.getDuration();
  }

  Future<String> _startBackingTrack(path) async {
    if (backingTrack.state == AudioPlayerState.PLAYING) {
      backingTrack.stop();
    }

    print("BACKING TRACK PLAYBACK STARTED...");
    return backingTrack.play(path, isLocal: true).toString();
  }

  void _stopBackingTrack() {
    print("backing track stopped!");

    if (backingTrack.state == AudioPlayerState.PLAYING) {
      backingTrack.stop();
    }
  }
}
