import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sound_controller.dart';
import '../providers/barks.dart';
import '../providers/image_controller.dart';
import './error_dialog.dart';

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
  //   AutomaticKeepAliveClientMixin {
  // bool get wantKeepAlive => true;
  AnimationController renameAnimationController;
  ImageController imageController;
  bool _isPlaying = false;
  final _controller = TextEditingController();
  String tempName;

  @override
  void initState() {
    tempName = widget.bark.name;
    renameAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    super.initState();
    renameAnimationController.forward();
    imageController = Provider.of<ImageController>(context, listen: false);
  }

  @override
  void dispose() {
    renameAnimationController.dispose();
    stopAll();
    super.dispose();
  }

  void stopAll() {
    if (_isPlaying) {
      setState(() => _isPlaying = false);
      imageController.stopAnimation();
      widget.soundController.stopPlayer();
    }
  }

  void startAll() async {
    setState(() => _isPlaying = true);
    imageController.mouthTrackSound(filePath: widget.bark.amplitudesPath);
    await widget.soundController.startPlayer(widget.bark.filePath, stopAll);
  }

  void playBark() async {
    try {
      startAll();
    } catch (e) {
      showErrorDialog(context, e.toString());
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
    _controller.text = tempName;
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: tempName.length,
    );
    void _submitNameChange(ctx) async {
      if (tempName == widget.bark.name)
        Navigator.of(ctx).pop();
      else if (tempName != "") {
        Navigator.of(ctx).pop();
        await renameAnimationController.reverse();
        setState(() {
          widget.bark.rename(tempName);
          widget.bark.name = tempName;
        });
        renameAnimationController.forward();
      } else {
        setState(() => tempName = widget.bark.name);
        Navigator.of(ctx).pop();
      }
    }

    await showDialog<Null>(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        title: Center(
          child: Text('Rename Bark'),
        ),
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

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: widget.animation,
      child: GestureDetector(
        onTap: () => renameBark(),
        child: Card(
          margin: EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 0,
          ),
          child: Padding(
            padding: EdgeInsets.all(0),
            child: ListTile(
              leading: IconButton(
                color: Colors.blue,
                onPressed: () {
                  playBark();
                },
                icon: Icon(Icons.play_arrow, color: Colors.black, size: 30),
              ),
              title: Center(
                child: FadeTransition(
                  opacity: renameAnimationController,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 18),
                      children: [
                        WidgetSpan(
                          child: Text(
                            widget.bark.getName,
                            // style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              subtitle: Center(child: Text(widget.bark.length)),
              trailing: IconButton(
                onPressed: () {
                  deleteBark();
                },
                icon: Icon(Icons.delete, color: Colors.redAccent, size: 30),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
