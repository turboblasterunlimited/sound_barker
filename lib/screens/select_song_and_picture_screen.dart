import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:K9_Karaoke/providers/sound_controller.dart';
import 'package:K9_Karaoke/screens/card_creator_screen.dart';
import '../providers/songs.dart';
import '../providers/pictures.dart';

import '../widgets/song_select_card.dart';
import '../widgets/select_picture_card.dart';

class SelectSongAndPictureScreen extends StatefulWidget {
  static const routeName = 'select-song-and-picture-screen';

  @override
  _SelectSongAndPictureScreenState createState() =>
      _SelectSongAndPictureScreenState();
}

class _SelectSongAndPictureScreenState
    extends State<SelectSongAndPictureScreen> {
  Picture selectedPicture;
  Song selectedSong;
  @override
  Widget build(BuildContext context) {
    final songs = Provider.of<Songs>(context);
    final pictures = Provider.of<Pictures>(context);
    final soundController =
        Provider.of<SoundController>(context, listen: false);

    void setSong(Song song) {
      setState(() {
        selectedSong = song;
      });
    }

    void setPicture(Picture picture) {
      setState(() {
        selectedPicture = picture;
      });
    }

    return Scaffold(
      // backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white, size: 30),
        centerTitle: true,
        title: Text(
          "Create a card",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GridView.builder(
              key: UniqueKey(),
              padding: const EdgeInsets.all(10),
              itemCount: pictures.all.length,
              itemBuilder: (ctx, i) => SelectPictureCard(
                  i, pictures.all[i], pictures, setPicture, selectedPicture?.fileId),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                // childAspectRatio: 3 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              key: UniqueKey(),
              padding: const EdgeInsets.all(10),
              itemCount: songs.all.length,
              itemBuilder: (ctx, i) => SongSelectCard(
                i,
                songs.all[i],
                soundController,
                setSong,
                selectedSong?.fileId,
              ),
            ),
          ),
          // Visibility(
          //   visible: selectedSongId != null && selectedPictureId != null,
          AnimatedOpacity(
            duration: Duration(milliseconds: 500),
            opacity:
                selectedSong != null && selectedPicture != null ? 1.0 : 0.0,
            child: ButtonBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                RawMaterialButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CardCreatorScreen(selectedSong, selectedPicture),
                      ),
                    );
                  },
                  child: Text(
                    "Next Step",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7.0),
                    // side: BorderSide(color: Colors.red),
                  ),
                  elevation: 2.0,
                  fillColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                ),
              ],
            ),
          ),
          // )
        ],
      ),
    );
  }
}
