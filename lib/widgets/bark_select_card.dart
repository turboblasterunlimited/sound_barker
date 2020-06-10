import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/screens/main_screen.dart';

import './error_dialog.dart';
import '../providers/sound_controller.dart';
import '../providers/barks.dart';
import '../providers/songs.dart';
import '../screens/bark_select_screen.dart';
import '../services/rest_api.dart';
import '../providers/spinner_state.dart';

class BarkSelectCard extends StatefulWidget {
  final Bark bark;
  final Map creatableSong;
  final SoundController soundController;
  final List selectedBarkIds;

  BarkSelectCard(this.bark, this.creatableSong, this.soundController,
      this.selectedBarkIds);

  @override
  _BarkSelectCardState createState() => _BarkSelectCardState();
}

class _BarkSelectCardState extends State<BarkSelectCard> {
  SpinnerState spinnerState;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    spinnerState = Provider.of<SpinnerState>(context, listen: false);
  }

  void playBark() async {
    setState(() {
      isPlaying = true;
    });
    try {
      widget.soundController.stopPlayer();
      widget.soundController.startPlayer(widget.bark.filePath);
    } catch (e) {
      showErrorDialog(context, e);
    }
  }

  void stopBark() {
    setState(() {
      isPlaying = false;
    });
    widget.soundController.stopPlayer();
  }

  void createSong(songs, songId) async {
    spinnerState.loadSongs();
    Map songData = await RestAPI.createSong(widget.selectedBarkIds, songId);
    Song song = Song();
    await song.retrieveSong(songData);
    print("ADDING SONG");
    songs.addSong(song);
    spinnerState.stopLoading();
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
              setState(() => widget.selectedBarkIds.add(widget.bark.fileId));
              if (widget.creatableSong["track_count"] >
                  widget.selectedBarkIds.length) {
                // If we need more barks for this song we select another bark.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BarkSelectScreen(widget.creatableSong,
                        selectedBarkIds: widget.selectedBarkIds),
                  ),
                );
              } else {
                // Else, create the song.
                createSong(songs, widget.creatableSong["id"]);
                Navigator.popUntil(
                  context,
                  ModalRoute.withName(MainScreen.routeName),
                );
                // setState((){});
              }
            },
            icon: Text(
              "Use",
              style: TextStyle(color: Colors.blue[800], fontSize: 16),
            ),
          ),
          title: Text(widget.bark.getName),
          trailing: IconButton(
            color: Colors.blue,
            onPressed: () {
              playBark();
            },
            icon: Icon(Icons.play_arrow, color: Colors.black, size: 30),
          ),
        ),
      ),
    );
  }
}
