import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundController with ChangeNotifier {
  AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
  AudioPlayer backingTrack = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);

  void stopPlayer() {
    if (audioPlayer.state == AudioPlayerState.PLAYING) {
      audioPlayer.stop();
      _stopBackingTrack();
    }
  }

  Future<void> startPlayer(path,
      [Function callback, String backingTrackPath]) async {
    if (audioPlayer.state == AudioPlayerState.PLAYING) {
      stopPlayer();
    }
    if (backingTrackPath != null) _startBackingTrack(backingTrackPath);

    // audioPlayer.monitorNotificationStateChanges();
    audioPlayer.play(path, isLocal: true);
    if (callback != null) {
      audioPlayer.onPlayerStateChanged.listen((playerState) =>
          {if (playerState == AudioPlayerState.STOPPED) callback()});
      audioPlayer.onPlayerCompletion.listen((event) {
        callback();
      });
    }
  }

  Future<String> _startBackingTrack(path) async {
    if (backingTrack.state == AudioPlayerState.PLAYING) {
      backingTrack.stop();
    }

    print("BACKING TRACK PLAYBACK STARTED...");
    return backingTrack.play(path, isLocal: true).toString();
  }

  void _stopBackingTrack() {
    if (backingTrack.state == AudioPlayerState.PLAYING) {
      backingTrack.stop();
    }
  }
}
