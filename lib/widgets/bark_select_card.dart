import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../functions/error_dialog.dart';
import '../providers/sound_controller.dart';
import '../providers/barks.dart';
import '../providers/songs.dart';

class BarkSelectCard extends StatefulWidget {
  final Bark bark;
  final Map creatableSong;
  final SoundController soundController;

  BarkSelectCard(this.bark, this.creatableSong, this.soundController);

  @override
  _BarkSelectCardState createState() => _BarkSelectCardState();
}

class _BarkSelectCardState extends State<BarkSelectCard> {
  void playBark() async {
    try {
      widget.soundController.stopPlayer();
      widget.soundController.startPlayer(widget.bark.filePath);
      widget.soundController.flutterSound.setVolume(1.0);
    } catch (e) {
      showErrorDialog(context, e);
    }
  }

  void createSong(songs, songId) async {
    String responseBody =
        await widget.bark.createSongOnServerAndRetrieve(songId);
    Song song = Song();
    song.retrieveSong(responseBody);
    songs.addSong(song);
  }

  @override
  Widget build(BuildContext context) {
    final songs = Provider.of<Songs>(context, listen: false);
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 3,
      ),
      child: Padding(
        padding: EdgeInsets.all(4),
        child: ListTile(
          leading: IconButton(
            onPressed: () {
              createSong(songs, widget.creatableSong["id"]);
              Navigator.popUntil(
                context,
                ModalRoute.withName(Navigator.defaultRouteName),
              );
            },
            icon: Text(
              "Use",
              style: TextStyle(color: Colors.blue[800], fontSize: 16),
            ),
          ),
          title: Text(widget.bark.name),
          trailing: IconButton(
            color: Colors.blue,
            onPressed: () {
              playBark();
            },
            icon: Icon(Icons.play_arrow, color: Colors.blueGrey, size: 40),
          ),
        ),
      ),
    );
  }
}
