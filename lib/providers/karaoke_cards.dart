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
  CardDecoration cardDecoration;
  KaraokeCard({this.fileId});
}