import 'dart:io';

import 'package:K9_Karaoke/classes/card_audio.dart';
import 'package:K9_Karaoke/classes/card_decoration_image.dart';
import 'package:K9_Karaoke/classes/card_message.dart';
import 'package:K9_Karaoke/classes/decoration.dart';
import 'package:K9_Karaoke/providers/barks.dart';
import 'package:K9_Karaoke/providers/creatable_songs.dart';
import 'package:K9_Karaoke/providers/pictures.dart';
import 'package:K9_Karaoke/providers/songs.dart';
import 'package:K9_Karaoke/tools/amplitude_extractor.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:K9_Karaoke/tools/ffmpeg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class KaraokeCards with ChangeNotifier {
  List<KaraokeCard> all = [];
  KaraokeCard current;

  void messageIsReady() {
    notifyListeners();
  }

  String get currentName {
    if (current == null || current.picture == null)
      return "test";
    else
      return current.picture.name;
  }

  void setCurrentSongFormula(CreatableSong creatableSong) {
    current.songFormula = creatableSong;
    notifyListeners();
  }

  void setCurrentName(newName) {
    current.picture.setName(newName);
    notifyListeners();
  }

  void setCurrentSong(Song newSong) {
    current.song = newSong;
    notifyListeners();
  }

  void setCurrentShortBark(bark) {
    current.shortBark = bark;
    notifyListeners();
  }

  void setCurrentMediumBark(bark) {
    current.mediumBark = bark;
    notifyListeners();
  }

  void setCurrentLongBark(bark) {
    current.longBark = bark;
    notifyListeners();
  }

  void setCurrentPicture(newPicture) {
    current.picture = newPicture;
    notifyListeners();
  }

  void setCurrent(card) {
    current = card;
    all.add(current);
    notifyListeners();
  }

  void newCurrent() {
    current = KaraokeCard();
    all.add(current);
    notifyListeners();
  }

  void setFrame(newFramePath) {
    current.shouldDeleteOldDecoration = true;
    current.framePath = newFramePath;
    notifyListeners();
  }

  bool get hasFrame {
    return current != null && current.framePath != null;
  }

  bool get currentPictureIsStock {
    return current.picture.isStock;
  }
}

class KaraokeCard with ChangeNotifier {
  String uuid;
  // This is a creatable song, which has two arrangments. One of the arrangement ids gets sent to the server with the bark ids to create an actual song.
  CreatableSong songFormula;
  // This is an actual song
  Song song;
  final message = CardMessage();
  Bark shortBark;
  Bark mediumBark;
  Bark longBark;
  CardAudio audio = CardAudio();
  // visual
  Picture picture;
  String framePath;
  CardDecoration decoration = CardDecoration();
  CardDecorationImage decorationImage;

  bool shouldDeleteOldDecoration = false;
  CardAudio oldCardAudio;

  setDecorationImage(decorationImage) {
    this.decorationImage = decorationImage;
    notifyListeners();
  }

  bool get isUsingDecorationImage {
    print("decorationImage: $decorationImage");
    print("shoulddeleteold: $shouldDeleteOldDecoration");
    return this.decorationImage != null && this.shouldDeleteOldDecoration == false;
  }

  Future<void> deleteOldDecorationImage() async {
    await decorationImage.delete();
    decorationImage = null;
  }

  Future<void> deleteOldAudio() async {
    await oldCardAudio.delete();
    oldCardAudio = null;
  }

  bool onlySong() {
    return !message.exists;
  }

  bool onlyMessage() {
    return song == null;
  }

  Future<void> combineMessageAndSong() async {
    audio.fileId = Uuid().v4();
    audio.filePath = File("$myAppStoragePath/${audio.fileId}.aac").path;
    File tempFile = File("$myAppStoragePath/tempFile.wav");
    // concat and save card audio file
    await FFMpeg.process.execute(
        '-i "concat:${message.path}|${song.filePath}" -c copy ${tempFile.path}');
    await FFMpeg.process.execute('-i ${tempFile.path} ${audio.filePath}');
    if (tempFile.existsSync()) tempFile.deleteSync();
    // concat and return amplitudes
    List songAmplitudes =
        await AmplitudeExtractor.fileToList(song.amplitudesPath);
    audio.amplitudes = message.amps + songAmplitudes;
  }

  void setPicture(Picture newPicture) {
    picture = newPicture;
    notifyListeners();
  }

  void setSong(Song newSong) {
    song = newSong;
    notifyListeners();
  }

  List<String> get barkIds {
    mediumBark ??= shortBark;
    longBark ??= mediumBark;
    return [shortBark.fileId, mediumBark.fileId, longBark.fileId];
  }

  bool get hasPicture {
    return picture != null;
  }

  bool get hasBarks {
    return shortBark != null;
  }

  bool get hasSong {
    return song != null;
  }

  bool get hasSongFormula {
    return songFormula != null;
  }

  bool get hasDecoration {
    return !decoration.isEmpty || decorationImage != null;
  }
}
