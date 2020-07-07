import 'package:K9_Karaoke/classes/card_decoration.dart';
import 'package:K9_Karaoke/providers/pictures.dart';
import 'package:K9_Karaoke/providers/songs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class KaraokeCards with ChangeNotifier {
  List<KaraokeCard> all = [];
  KaraokeCard currentCard;

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

  bool get hasDecoration {
    return cardDecoration != null || decorationImagePath != null;
  }
}
