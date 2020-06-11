import 'package:flutter/material.dart';
import 'package:K9_Karaoke/screens/bark_select_screen.dart';

import '../widgets/error_dialog.dart';
import '../providers/sound_controller.dart';

class CreatableSongCard extends StatefulWidget {
  final creatableSong;
  final SoundController soundController;

  CreatableSongCard(this.creatableSong, this.soundController);

  @override
  _CreatableSongCardState createState() => _CreatableSongCardState();
}

class _CreatableSongCardState extends State<CreatableSongCard> {
  bool isPlaying = false;

  @override
  void dispose() {
    widget.soundController.stopPlayer();
    super.dispose();
  }

  Function stopPlayerCallBack() {
    return () {
      widget.soundController.stopPlayer();
      if (mounted) setState(() => isPlaying = false);
    };
  }

  void playSong() async {
    try {
      await widget.soundController.startPlayer(
          "https://storage.googleapis.com/song_barker_sequences/" + widget.creatableSong["backing_track_bucket_fp"],
          stopPlayerCallBack(),
          false);
    } catch (e) {
      showErrorDialog(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(5)),
      child: Container(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BarkSelectScreen(widget.creatableSong, selectedBarkIds: []),
              ),
            );
          },
          child: Card(
            margin: EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 3,
            ),
            child: Padding(
              padding: EdgeInsets.all(4),
              child: ListTile(
                leading: Icon(Icons.music_note, color: Colors.black, size: 40),
                title: Text(widget.creatableSong["name"] +
                    " - " +
                    widget.creatableSong["song_family"]),
                trailing: IconButton(
                  color: Colors.blue,
                  onPressed: () {
                    print("Song Source: ${widget.creatableSong["backing_track_bucket_fp"]}");
                    if (isPlaying) {
                      widget.soundController.stopPlayer();
                    } else {
                      playSong();
                      Future.delayed(Duration(milliseconds: 50), () {
                        setState(() => isPlaying = true);
                      });
                    }
                  },
                  icon: isPlaying
                      ? Icon(Icons.stop, color: Colors.blueGrey, size: 30)
                      : Text("preview"),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
