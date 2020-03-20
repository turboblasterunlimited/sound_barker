import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sound_controller.dart';
import '../providers/barks.dart';
import '../providers/image_controller.dart';
import '../functions/error_dialog.dart';
import '../services/wave_streamer.dart' as WaveStreamer;

class BarkPlaybackCard extends StatefulWidget {
  final int index;
  final Bark bark;
  final Barks barks;
  final SoundController soundController;
  final Animation<double> animation;
  BarkPlaybackCard(
      this.index, this.bark, this.barks, this.soundController, this.animation);

  @override
  _BarkPlaybackCardState createState() => _BarkPlaybackCardState();
}

class _BarkPlaybackCardState extends State<BarkPlaybackCard>
    with TickerProviderStateMixin {
  AnimationController renameAnimationController;

  @override
  void initState() {
    renameAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    super.initState();
    renameAnimationController.forward();
  }

  @override
  void dispose() {
    widget.soundController.stopPlayer();
    super.dispose();
  }

  void playBark() async {
    final imageController =
        Provider.of<ImageController>(context, listen: false);
    try {
      WaveStreamer.performAudio(widget.bark.filePath, imageController);
      widget.soundController.stopPlayer();
      widget.soundController.startPlayer(widget.bark.filePath);
      widget.soundController.flutterSound.setVolume(1.0);
    } catch (e) {
      showErrorDialog(context, e);
    }
  }

  void deleteBark() async {
    await showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Are you sure you want to delete ${widget.bark.name}?'),
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
                  widget.barks.remove(widget.bark);
                  AnimatedList.of(context).removeItem(
                      widget.index,
                      (context, animation) => BarkPlaybackCard(
                          widget.index,
                          widget.bark,
                          widget.barks,
                          widget.soundController,
                          animation));
                } catch (e) {
                  showErrorDialog(context, e);
                }
              })
        ],
      ),
    );
  }

  void renameBark() async {

    void _submitNameChange(ctx) async {
      try {
        widget.bark.rename(widget.bark.name);
      } catch (e) {
        showErrorDialog(context, e);
      }
      Navigator.of(ctx).pop();
      await renameAnimationController.reverse();
      setState((){});
      renameAnimationController.forward();
    }

    await showDialog<Null>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Rename Sound'),
        contentPadding: EdgeInsets.all(10),
        titlePadding: EdgeInsets.all(10),
        children: <Widget>[
          TextFormField(
            initialValue: widget.bark.name,
            onChanged: (newName) {
              widget.bark.name = newName;
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
              child: Text("NEVERMIND"),
              onPressed: () {
                Navigator.of(ctx).pop();
              }),
          FlatButton(
            child: Text('RENAME'),
            onPressed: () {
              _submitNameChange(ctx);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: widget.animation,
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 3,
        ),
        child: Padding(
          padding: EdgeInsets.all(4),
          child: ListTile(
            leading: IconButton(
              color: Colors.blue,
              onPressed: () {
                playBark();
              },
              icon: Icon(Icons.play_arrow, color: Colors.black, size: 40),
            ),
            title: GestureDetector(
              onTap: () {
                try {
                  renameBark();
                } catch (e) {
                  showErrorDialog(context, e);
                }
              },
              child: Center(
                child: FadeTransition(
                  opacity: renameAnimationController,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 18),
                      children: [
                        WidgetSpan(
                          child: Text(widget.bark.name),
                        ),
                        WidgetSpan(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Icon(Icons.edit,
                                color: Colors.blueGrey, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // subtitle: Text(pet.name),
            trailing: IconButton(
              onPressed: () {
                deleteBark();
              },
              icon: Icon(Icons.delete, color: Colors.redAccent, size: 30),
            ),
          ),
        ),
      ),
    );
  }
}
