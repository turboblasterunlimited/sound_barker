import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_barker/providers/tab_list_scroll_controller.dart';
import 'dart:async';

import '../providers/sound_controller.dart';
import '../providers/songs.dart';
import '../widgets/error_dialog.dart';
import '../providers/image_controller.dart';

class SongPlaybackCard extends StatefulWidget {
  final int index;
  final Song song;
  final Songs songs;
  final SoundController soundController;
  final Animation animation;
  SongPlaybackCard(
      this.index, this.song, this.songs, this.soundController, this.animation);

  @override
  _SongPlaybackCardState createState() => _SongPlaybackCardState();
}

class _SongPlaybackCardState extends State<SongPlaybackCard>
    with TickerProviderStateMixin {
  //   AutomaticKeepAliveClientMixin {
  // bool get wantKeepAlive => true;
  ImageController imageController;
  AnimationController renameAnimationController;
  bool isPlaying = false;
  TabListScrollController tabListScrollController;
  final _controller = TextEditingController();
  String tempName;

  @override
  void initState() {
    imageController = Provider.of<ImageController>(context, listen: false);
    renameAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    super.initState();
    renameAnimationController.forward();
    tabListScrollController =
        Provider.of<TabListScrollController>(context, listen: false);
  }

  @override
  void dispose() {
    renameAnimationController.dispose();
    super.dispose();
  }

  void stopAll() {
    imageController.stopAnimation();
    widget.soundController.stopPlayer();
  }

  Function stopPlayerCallBack() {
    return () {
      stopAll();
      if (mounted) setState(() => isPlaying = false);
    };
  }

  void startAll() async {
    stopAll();
    imageController.mouthTrackSound(widget.song.amplitudesPath);
    await widget.soundController
        .startPlayer(widget.song.filePath, stopPlayerCallBack());
    print("song playback file path: ${widget.song.filePath}");
  }

  void playSong(context) async {
    try {
      stopAll();
      startAll();
    } catch (e) {
      showErrorDialog(context, e);
    }
  }

  void deleteSong() async {
    await showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Are you sure you want to delete ${widget.song.name}?'),
        actions: <Widget>[
          FlatButton(
              child: Text("No, Don't delete it."),
              onPressed: () {
                Navigator.of(ctx).pop();
              }),
          FlatButton(
              child: Text('Yes. Delete it.'),
              onPressed: () {
                Navigator.of(ctx).pop();
                try {
                  widget.songs.removeSong(widget.song);
                  AnimatedList.of(context).removeItem(
                      widget.index,
                      (context, animation) => SongPlaybackCard(
                          widget.index,
                          widget.song,
                          widget.songs,
                          widget.soundController,
                          animation));
                } catch (e) {
                  showErrorDialog(ctx, e.toString());
                } finally {}
              })
        ],
      ),
    );
  }

  void renameSong() async {
    _controller.text = widget.song.name;
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.song.name.length,
    );
    void _submitNameChange(ctx) async {
      widget.song.rename(tempName);
      Navigator.of(ctx).pop();
      await renameAnimationController.reverse();
      setState(() => widget.song.name = tempName);
      renameAnimationController.forward();
    }

    await showDialog<Null>(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: Center(child: Text('Rename Song')),
        contentPadding: EdgeInsets.all(10),
        titlePadding: EdgeInsets.all(10),
        children: <Widget>[
          TextFormField(
            controller: _controller,
            autofocus: true,
            onChanged: (newName) {
              setState(() => tempName = newName);
            },
            onFieldSubmitted: (_) {
              _submitNameChange(ctx);
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'Please provide a name.';
              }
              return null;
            },
          ),
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              _submitNameChange(ctx);
            },
          ),
        ],
      ),
    );
  }

  void handleTabScroll() {
    if (tabListScrollController.tabExtent == 0.8) {
      var position = tabListScrollController.scrollController.position.pixels;
      position += 250;
      DraggableScrollableActuator.reset(context);
      Future.delayed(Duration(milliseconds: 100)).then((_) {
        tabListScrollController.scrollController.jumpTo(position);
      });
      tabListScrollController.updateTabExtent(0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Song name: ${widget.song.name}");
    return SizeTransition(
      sizeFactor: widget.animation,
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 3,
        ),
        child: Padding(
          padding: EdgeInsets.all(0),
          child: ListTile(
            leading: IconButton(
              color: Colors.blue,
              onPressed: () {
                if (isPlaying) {
                  stopAll();
                } else {
                  playSong(context);
                  Future.delayed(Duration(milliseconds: 50), () {
                    setState(() => isPlaying = true);
                  });
                  handleTabScroll();
                }
              },
              icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow,
                  color: Colors.black, size: 30),
            ),
            title: GestureDetector(
              onTap: () => renameSong(),
              child: Center(
                child: FadeTransition(
                  opacity: renameAnimationController,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 18),
                      children: [
                        WidgetSpan(
                          child: Text(widget.song.name ?? "Unknown",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        // WidgetSpan(
                        //   child: Padding(
                        //     padding:
                        //         const EdgeInsets.symmetric(horizontal: 2.0),
                        //     child: Icon(Icons.edit,
                        //         color: Colors.grey[400], size: 16),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // subtitle: Text(pet.name),
            trailing: IconButton(
              onPressed: () {
                deleteSong();
              },
              icon: Icon(Icons.delete, color: Colors.redAccent, size: 30),
            ),
          ),
        ),
      ),
    );
  }
}
