import 'package:flutter/material.dart';

import '../functions/error_dialog.dart';
import '../providers/sound_controller.dart';
import '../providers/songs.dart';


class SongSelectCard extends StatefulWidget {
  final int index;
  final Song song;
  final SoundController soundController;
  final Function setSongId;
  final String selectedSongId;

  SongSelectCard(this.index, this.song, this.soundController, this.setSongId,
      this.selectedSongId);

  @override
  _SongSelectCardState createState() => _SongSelectCardState();
}

class _SongSelectCardState extends State<SongSelectCard> {
  bool isSelected;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    isSelected = widget.selectedSongId == widget.song.fileId;
  }

  @override
  void dispose() {
    stopAll();
    super.dispose();
  }

  void stopAll() {
    widget.soundController.stopPlayer(widget.song.backingTrackPath != null);
  }

  void playSong() async {
    try {
      widget.soundController.stopPlayer(widget.song.backingTrackPath != null);
      int timeLeft = await widget.soundController
          .startPlayer(widget.song.filePath, widget.song.backingTrackPath);
      resetIsPlayingAfterDelay(timeLeft);
    } catch (e) {
      showErrorDialog(context, e);
    }
  }

  void resetIsPlayingAfterDelay(int timeLeft) async {
    Future.delayed(Duration(milliseconds: timeLeft), () {
      if (this.mounted && isPlaying) setState(() => isPlaying = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    selectThis() {
      widget.setSongId(widget.song.fileId);
    }

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(5)),
      child: Container(
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: Colors.blueAccent, width: 5)
              : Border.all(width: 0, color: Colors.transparent),
        ),
        child: Card(
          // margin: EdgeInsets.symmetric(
          //   horizontal: 5,
          //   vertical: 3,
          // ),
          child: Padding(
            padding: EdgeInsets.all(0),
            child: ListTile(
              leading: GestureDetector(
                onTap: () {
                  selectThis();
                },
                child: isSelected
                    ? Icon(
                        Icons.check_box,
                        color: Colors.blueAccent,
                      )
                    : Icon(Icons.check_box_outline_blank),
              ),
              title: Center(
                child: GestureDetector(
                  onTap: () {
                    selectThis();
                  },
                  child: Text(widget.song.name),
                ),
              ),
              trailing: IconButton(
                color: Colors.blue,
                onPressed: () {
                  if (isPlaying) {
                    setState(() => isPlaying = false);
                    stopAll();
                  } else {
                    setState(() => isPlaying = true);
                    playSong();
                  }
                },
                icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow,
                    color: Colors.blueGrey, size: 30),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
