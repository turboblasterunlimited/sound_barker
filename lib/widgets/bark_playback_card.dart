import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_barker/providers/tab_list_scroll_controller.dart';

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
  bool isPlaying = false;
  TabListScrollController tabListScrollController;
  final _controller = TextEditingController();
  String tempName;

  @override
  void initState() {
    tabListScrollController =
        Provider.of<TabListScrollController>(context, listen: false);
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
    imageController.stopAnimation();
    widget.soundController.stopPlayer();
  }

  void startAll() async {
    print("bark amplitudespath: ${widget.bark.amplitudesPath}");
    print("bark filepath: ${widget.bark.filePath}");

    imageController.mouthTrackSound(widget.bark.amplitudesPath);
    await widget.soundController.startPlayer(widget.bark.filePath);
  }

  void playBark() async {
    try {
      stopAll();
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
    _controller.text = widget.bark.name;
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.bark.name.length,
    );
    void _submitNameChange(ctx) async {
      widget.bark.rename(tempName);
      Navigator.of(ctx).pop();
      await renameAnimationController.reverse();
      setState(() {
        widget.bark.name = tempName;
      });
      renameAnimationController.forward();
    }

    await showDialog<Null>(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
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
                playBark();
                handleTabScroll();
              },
              icon: Icon(Icons.play_arrow, color: Colors.black, size: 30),
            ),
            title: GestureDetector(
              onTap: () => renameBark(),
              child: Center(
                child: FadeTransition(
                  opacity: renameAnimationController,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 18),
                      children: [
                        WidgetSpan(
                          child: Text(widget.bark.getName,
                              style: TextStyle(fontWeight: FontWeight.bold)),
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
