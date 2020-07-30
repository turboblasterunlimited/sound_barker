import 'package:K9_Karaoke/classes/card_decoration.dart';
import 'package:K9_Karaoke/classes/card_message.dart';
import 'package:K9_Karaoke/providers/barks.dart';
import 'package:K9_Karaoke/providers/creatable_songs.dart';
import 'package:K9_Karaoke/providers/pictures.dart';
import 'package:K9_Karaoke/providers/songs.dart';
import 'package:K9_Karaoke/services/gcloud.dart';
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class KaraokeCards with ChangeNotifier {
  List<KaraokeCard> all = [];
  KaraokeCard current;

  String get currentName {
    if (current == null || current.picture == null)
      return "test";
    else
      return current.picture.name;
  }

  void setCurrentSongFormula(CreatableSong creatableSong) {
    // remove actual song if user changes the song formula
    current.song = null;
    current.songFormula = creatableSong;
    notifyListeners();
  }

  void setCurrentName(newName) {
    current.picture.setName(newName);
    notifyListeners();
  }

  void setCurrentSong(newSong) {
    // retain song formula when new song is added, in case user wants to go back and make a new song
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

  bool get currentPictureIsStock {
    return current.picture.isStock;
  }
}

class KaraokeCard with ChangeNotifier {
  final message = CardMessage();
  String fileId;
  Picture picture;
  // This is a creatable song, which has two arrangments. One of the arrangement ids gets sent to the server with the bark ids to create an actual song.
  CreatableSong songFormula;
  // This is an actual song
  Song song;
  List<String> barks = [];
  // if editing a previously generated card
  String decorationImagePath;
  // if making a new card
  CardDecoration cardDecoration;
  Bark shortBark;
  Bark mediumBark;
  Bark longBark;
  String audioFilePath;

  KaraokeCard(
      {this.fileId,
      this.picture,
      this.song,
      this.songFormula,
      this.shortBark,
      this.mediumBark,
      this.longBark,
      this.cardDecoration,
      this.decorationImagePath,
      this.audioFilePath});

  void uploadAudio() {
    Gcloud.uploadCardAssets(audioFilePath, picture.filePath);
    RestAPI.createCard(decorationImageId, audioId, amplitudes, imageId)
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
    return cardDecoration != null || decorationImagePath != null;
  }
}
