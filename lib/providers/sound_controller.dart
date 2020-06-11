import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundController with ChangeNotifier {
  AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);

  void stopPlayer() {
    if (audioPlayer.state == AudioPlayerState.PLAYING) {
      audioPlayer.stop();
    }
  }

  Future<void> startPlayer(path,
      [Function callback, bool isLocal = true]) async {
    if (audioPlayer.state == AudioPlayerState.PLAYING) {
      stopPlayer();
    }

    audioPlayer.play(path, isLocal: isLocal);
    if (callback != null) {
      audioPlayer.onPlayerStateChanged.listen((playerState) =>
          {if (playerState == AudioPlayerState.STOPPED) callback()});
      audioPlayer.onPlayerCompletion.listen((event) {
        callback();
      });
    }
  }

}
