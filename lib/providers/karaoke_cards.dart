import 'package:K9_Karaoke/classes/card_decoration.dart';
import 'package:K9_Karaoke/providers/barks.dart';
import 'package:K9_Karaoke/providers/creatable_songs.dart';
import 'package:K9_Karaoke/providers/pictures.dart';
import 'package:K9_Karaoke/providers/songs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class KaraokeCards with ChangeNotifier {
  List<KaraokeCard> all = [];
  KaraokeCard currentCard;

  String get currentCardName {
    if (currentCard == null || currentCard.picture == null)
      return "test";
    else
      return currentCard.picture.name;
  }

  void setCurrentCardSongFormula(CreatableSong creatableSong) {
    // also remove song if that is selected
    currentCard.song = null;
    currentCard.songFormula = creatableSong;
    notifyListeners();
  }

  void setCurrentCardName(newName) {
    currentCard.picture.setName(newName);
    notifyListeners();
  }

  void setCurrentCardSong(newSong) {
    // also remove song if that is selected
    currentCard.songFormula = null;
    currentCard.song = newSong;
    notifyListeners();
  }

  void setCurrentCardShortBark(bark) {
    currentCard.shortBark = bark;
    notifyListeners();
  }

  void setCurrentCardMediumBark(bark) {
    currentCard.mediumBark = bark;
    notifyListeners();
  }

  void setCurrentCardLongBark(bark) {
    currentCard.longBark = bark;
    notifyListeners();
  }

  void setCurrentCardPicture(newPicture) {
    currentCard.picture = newPicture;
    notifyListeners();
  }

  void setCurrentCard(card) {
    currentCard = card;
    all.add(currentCard);
    notifyListeners();
  }

  void newCurrentCard() {
    currentCard = KaraokeCard();
    all.add(currentCard);
    notifyListeners();
  }

  bool get currentPictureIsStock {
    return currentCard.picture.isStock;
  }
}

class KaraokeCard with ChangeNotifier {
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

  KaraokeCard(
      {this.fileId,
      this.picture,
      this.song,
      this.songFormula,
      this.shortBark,
      this.mediumBark,
      this.longBark,
      this.cardDecoration,
      this.decorationImagePath});

  void setPicture(Picture newPicture) {
    picture = newPicture;
    notifyListeners();
  }

  List<String> get barkIds {
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
