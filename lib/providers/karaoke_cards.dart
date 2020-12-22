import 'dart:convert';
import 'dart:io';

import 'package:K9_Karaoke/providers/card_audio.dart';
import 'package:K9_Karaoke/providers/card_decoration_image.dart';
import 'package:K9_Karaoke/classes/card_message.dart';
import 'package:K9_Karaoke/classes/decoration.dart';
import 'package:K9_Karaoke/providers/barks.dart';
import 'package:K9_Karaoke/providers/creatable_songs.dart';
import 'package:K9_Karaoke/providers/pictures.dart';
import 'package:K9_Karaoke/providers/songs.dart';
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:K9_Karaoke/tools/amplitude_extractor.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:K9_Karaoke/tools/ffmpeg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:K9_Karaoke/globals.dart';

class KaraokeCards with ChangeNotifier {
  List<KaraokeCard> all = [];
  KaraokeCard current;

  List<KaraokeCard> get saved {
    return all.where((KaraokeCard card) => card.uuid != null).toList();
  }

  void removeAll() {
    all = [];
  }

  void addCurrent() {
    all.add(current);
  }

  void deleteAll() {
    all.forEach((card) => card.removeFiles());
  }

  Future<void> remove(KaraokeCard card) async {
    print("TODO: implement delete");
    await RestAPI.deleteCardAudio(card.audio.fileId);
    if (card.decorationImage != null)
      await RestAPI.deleteDecorationImage(card.decorationImage.fileId);
    await RestAPI.deleteCard(card);
    all.remove(card);
    card.removeFiles();
  }

  void messageIsReady() {
    notifyListeners();
  }

  Future<void> retrieveAll(Pictures pictures, CardAudios audios, Songs songs,
      CardDecorationImages decorations) async {
    var response = await RestAPI.retrieveAllCards();
    response.forEach((cardData) {
      if (cardData["hidden"] == 1) return;

      try {
        final card = KaraokeCard(
          uuid: cardData["uuid"],
          picture: pictures.findById(cardData["image_id"]),
          decorationImage:
              decorations.findById(cardData["decoration_image_id"]),
        );
        card.audio = audios.findById(cardData["card_audio_id"]);
        card.audio.amplitudes =
            json.decode(cardData["animation_json"])["mouth_positions"];
        all.add(card);
      } catch (e) {
        print(e);
        return;
      }
    });
    notifyListeners();
  }

  String get currentName {
    return current?.picture?.name ?? "";
  }

  void setCurrentSongFormula(CreatableSong creatableSong) {
    current.songFormula = creatableSong;
    notifyListeners();
  }

  void setCurrentName(String newName) {
    current.picture.setName(newName);
    notifyListeners();
  }

  void setCurrentSong(Song newSong) {
    current.setSong(newSong);
    current.markLastAudioForDelete();
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
    if (current.uuid != null) RestAPI.updateCardPicture(current);
    notifyListeners();
  }

  void setCurrent(card) {
    current = card;
    notifyListeners();
  }

  void newCurrent() {
    current = KaraokeCard();
    notifyListeners();
  }

  bool get hasFrame {
    return current != null && current.hasFrame;
  }

  bool get currentPictureIsStock {
    return current.picture != null && current.picture.isStock;
  }

  bool get hasPicture {
    return current != null && current.hasPicture;
  }
}

class KaraokeCard with ChangeNotifier {
  // completed components
  String uuid;
  Picture picture;
  CardAudio audio;
  CardDecorationImage decorationImage;

  // used to create or manage card components
  CreatableSong
      songFormula; // This is a creatable song, which has two arrangments. One of the arrangement ids gets sent to the server with the bark ids to create an actual song.
  Song song; // This is an actual song
  final message = CardMessage();
  Bark shortBark;
  Bark mediumBark;
  Bark longBark;
  String framePath;
  CardDecoration decoration = CardDecoration();
  bool shouldDeleteOldDecoration = false;
  CardAudio oldCardAudio;
  bool framelessIsSelected = false;

  KaraokeCard(
      {this.uuid, this.picture, this.audio, this.song, this.decorationImage}) {
    this.audio ??= CardAudio();
  }

  bool hasBark(bark) {
    return bark == shortBark || bark == mediumBark || bark == longBark;
  }

  void removeFiles() {
    try {
      if (decorationImage != null &&
          File(decorationImage.filePath).existsSync())
        File(decorationImage.filePath).deleteSync();
      if (File(audio.filePath).existsSync()) File(audio.filePath).deleteSync();
    } catch (e) {
      print(e);
    }
  }

  bool get noFrameOrDecoration {
    return !hasFrame && decoration.isEmpty;
  }

  bool get hasFrame {
    return framePath != null;
  }

  bool get hasFrameDimension {
    if (framelessIsSelected) return false;
    return hasFrame ||
        (decorationImage != null && decorationImage.hasFrameDimension);
  }

  void setDecorationImage(decorationImage) {
    this.decorationImage = decorationImage;
    this.shouldDeleteOldDecoration = false;
    notifyListeners();
  }

  bool get isUsingDecorationImage {
    print("decorationImage: $decorationImage");
    print("shoulddeleteold: $shouldDeleteOldDecoration");
    return this.decorationImage != null &&
        this.shouldDeleteOldDecoration == false;
  }

  Future<void> deleteOldDecorationImage() async {
    await decorationImage.delete();
    decorationImage = null;
  }

  void setShouldDeleteOldDecortionImage() {
    if (decorationImage != null && decorationImage.exists)
      shouldDeleteOldDecoration = true;
  }

  Future<void> deleteOldAudio() async {
    await oldCardAudio.delete();
    oldCardAudio = null;
  }

  bool onlySong() {
    return !hasMessage && hasASong;
  }

  bool onlyMessage() {
    return song == null && hasMessage;
  }

  void markLastAudioForDelete() {
    if (audio.exists) oldCardAudio = audio;
  }

  Future<void> combineMessageAndSong() async {
    // if already have a combined audio file
    markLastAudioForDelete();
    audio = CardAudio();
    audio.filePath = "$myAppStoragePath/${audio.fileId}.aac";

    // Combine with song
    if (hasASong) {
      File tempFile = File("$myAppStoragePath/tempFile.wav");
      // concat and save card audio file
      await FFMpeg.process.execute(
          '-i "concat:${message.path}|${song.filePath}" -ac 1 ${tempFile.path}');
      await FFMpeg.process.execute('-i ${tempFile.path} ${audio.filePath}');
      if (tempFile.existsSync()) tempFile.deleteSync();
      // concat and return amplitudes
      List<double> songAmplitudes =
          await AmplitudeExtractor.fileToList(song.amplitudesPath);
      audio.amplitudes = message.amps + songAmplitudes;
    } else {
      // make card.message into card.audio
      File(message.path).copySync(audio.filePath);
      audio.amplitudes = message.amps;
    }
  }

  Future<void> songToAudio() async {
    markLastAudioForDelete();
    audio = CardAudio();
    audio.filePath = "$myAppStoragePath/${audio.fileId}.aac";
    File(song.filePath).copySync(audio.filePath);
    audio.amplitudes = await AmplitudeExtractor.fileToList(song.amplitudesPath);
    notifyListeners();
  }

  void setPicture(Picture newPicture) {
    picture = newPicture;
    notifyListeners();
  }

  void setSong(Song newSong) {
    song = newSong;
    if (decorationImage == null && decoration.isEmpty) {
      String selectedFrame = songFamilyToCardFileName[song.songFamily];
      setFrame(selectedFrame);
      print("selectedFrame: $selectedFrame");
    }
    notifyListeners();
  }

  void setFrame(newFrameFileName, [bool hasFrameDimensions = false]) {
    if (hasFrameDimensions)
      framelessIsSelected = false;
    else
      framelessIsSelected = newFrameFileName == null ? true : false;
    setShouldDeleteOldDecortionImage();
    framePath = framesPath + newFrameFileName;
    notifyListeners();
  }

  void noSongNoFormula() {
    song = null;
    songFormula = null;
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

  bool get hasASong {
    return song != null;
  }

  bool hasSong(songToCheck) {
    return song == songToCheck;
  }

  bool get hasMessage {
    return message.exists;
  }

  bool get hasAudio {
    return audio.exists;
  }

  bool get hasASongFormula {
    return songFormula != null;
  }

  bool get hasDecoration {
    return !decoration.isEmpty || decorationImage != null;
  }
}
