import 'package:K9_Karaoke/providers/card_audio.dart';
import 'package:K9_Karaoke/providers/card_decoration_image.dart';
import 'package:K9_Karaoke/providers/barks.dart';
import 'package:K9_Karaoke/providers/creatable_songs.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/pictures.dart';
import 'package:K9_Karaoke/providers/songs.dart';
import 'package:K9_Karaoke/screens/main_screen.dart';

import 'package:K9_Karaoke/widgets/loading_screen_widget.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class RetrieveDataScreen extends StatefulWidget {
  static const routeName = 'retrieve-data-screen';

  @override
  _RetrieveDataScreenState createState() => _RetrieveDataScreenState();
}

class _RetrieveDataScreenState extends State<RetrieveDataScreen> {
  Barks barks;
  Songs songs;
  Pictures pictures;
  CreatableSongs creatableSongs;
  CardAudios cardAudios;
  CardDecorationImages decorationImages;
  KaraokeCards cards;
  bool firstBuild = true;

  Future<void> downloadDataAndNavigate() async {
    if (!mounted) return;
    await pictures.retrieveAll();
    // need creatableSongData to get songIds
    await creatableSongs.retrieveFromServer();
    await barks.retrieveAll();
    songs.setCreatableSongs(creatableSongs);
    await songs.retrieveAll();
    await cardAudios.retrieveAll();
    await decorationImages.retrieveAll();
    await cards.retrieveAll(pictures, cardAudios, songs, decorationImages);
    Navigator.of(context).popAndPushNamed(MainScreen.routeName);
  }

  @override
  Widget build(BuildContext ctx) {
    barks = Provider.of<Barks>(context, listen: false);
    songs = Provider.of<Songs>(context, listen: false);
    pictures = Provider.of<Pictures>(context, listen: false);
    creatableSongs = Provider.of<CreatableSongs>(context, listen: false);
    cardAudios = Provider.of<CardAudios>(context, listen: false);
    decorationImages =
        Provider.of<CardDecorationImages>(context, listen: false);
    cards = Provider.of<KaraokeCards>(context, listen: false);
    if (firstBuild) {
      setState(() => firstBuild = false);
      downloadDataAndNavigate();
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: LoadingScreenWidget("Getting your stuff!"));
  }
}
