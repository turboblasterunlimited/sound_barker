import 'package:K9_Karaoke/classes/card_decoration.dart';
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

  void setCurrentCardSongFormulaId(int id) {
    currentCard.songFormulaId = id.toString();
    notifyListeners();
  }

  void setCurrentCardName(newName) {
    currentCard.picture.name = newName;
    notifyListeners();
  }

  void setCurrentCardSong(newSong) {
    currentCard.song = newSong;
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
}

class KaraokeCard with ChangeNotifier {
  String fileId;
  Picture picture;
  // This is a creatable song id that gets sent to the server with the bark ids to create an actual song.
  String songFormulaId;
  // This is an actual song
  Song song;
  List<String> barks = [];
  // if editing a previously generated card
  String decorationImagePath;
  // if making a new card
  CardDecoration cardDecoration;
  KaraokeCard(
      {this.fileId,
      this.picture,
      this.song,
      this.songFormulaId,
      this.barks,
      this.cardDecoration,
      this.decorationImagePath});

  void setPicture(Picture newPicture) {
    picture = newPicture;
    notifyListeners();
  }

  bool get hasPicture {
    return picture != null;
  }

  bool get hasBarks {
    return barks != null;
  }

  bool get hasSong {
    return song != null;
  }

  bool get hasSongFormula {
    return songFormulaId != null;
  }

  bool get hasDecoration {
    return cardDecoration != null || decorationImagePath != null;
  }
}
