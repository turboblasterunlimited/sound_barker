import 'package:flutter/material.dart';

import '../widgets/error_dialog.dart';
import '../providers/sound_controller.dart';
import '../providers/songs.dart';

class SongSelectCard extends StatefulWidget {
  final int index;
  final Song song;
  final SoundController soundController;
  final Function setSong;
  final String selectedSongId;

  SongSelectCard(this.index, this.song, this.soundController, this.setSong,
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
      widget.soundController.stopPlayer();
      await widget.soundController.startPlayer(widget.song.filePath,
          stopPlayerCallBack());
    } catch (e) {
      showErrorDialog(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    selectThis() {
      widget.setSong(widget.song);
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
                    widget.soundController.stopPlayer();
                  } else {
                    playSong();
                    Future.delayed(Duration(milliseconds: 50), () {
                      setState(() => isPlaying = true);
                    });
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
