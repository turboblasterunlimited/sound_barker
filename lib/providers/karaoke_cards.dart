import 'package:K9_Karaoke/classes/card_decoration.dart';
import 'package:K9_Karaoke/providers/pictures.dart';
import 'package:K9_Karaoke/providers/songs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';


class KaraokeCards with ChangeNotifier {
  List<KaraokeCard> all = [];
}

class KaraokeCard {
  String fileId;
  Picture picture;
  Song song;
  // if editing a previously generated card
  String decorationImagePath;
  // if making a new card
  CardDecoration cardDecoration;
  KaraokeCard({this.fileId, this.picture, this.song, this.cardDecoration, this.decorationImagePath});
}