import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../providers/sound_controller.dart';
import '../providers/barks.dart';
import '../providers/image_controller.dart';
import '../functions/error_dialog.dart';

class BarkPlaybackCard extends StatefulWidget {
  final int index;
  final Bark bark;
  final SoundController soundController;
  BarkPlaybackCard(this.index, this.bark, this.soundController);

  @override
  _BarkPlaybackCardState createState() => _BarkPlaybackCardState();
}

class _BarkPlaybackCardState extends State<BarkPlaybackCard> {
  @override
  void dispose() {
    widget.soundController.stopPlayer();
    super.dispose();
  }

  void playBark() async {
    Provider.of<ImageController>(context, listen: false).triggerBark();
    String path = widget.bark.filePath;

    if (File(path).exists() == null) {
      return;
    }
    try {
      path = await widget.soundController.startPlayer(path);
      await widget.soundController.flutterSound.setVolume(1.0);
    } catch (e) {
      print("Error: $e");
    }
  }

  void deleteBark(bark) async {
    final barks = Provider.of<Barks>(context, listen: false);
    await showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Are you sure you want to delete ${bark.name}?'),
        actions: <Widget>[
          FlatButton(
              child: Text("No, Don't delete it."),
              onPressed: () {
                Navigator.of(ctx).pop();
              }),
          FlatButton(
              child: Text('Yes. Delete it.'),
              onPressed: () {
                try {
                  barks.remove(bark);
                } catch (e) {
                  showErrorDialog(context, e);
                } finally {
                  Navigator.of(ctx).pop();
                }
              })
        ],
      ),
    );
  }

  void renameBark(bark) async {
    String newName = bark.name;

    void _submitNameChange(ctx) {
      try {
        bark.rename(newName);
      } catch (e) {
        showErrorDialog(context, e);
      }
      Navigator.of(ctx).pop();
    }

    await showDialog<Null>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Rename Sound'),
        contentPadding: EdgeInsets.all(10),
        titlePadding: EdgeInsets.all(10),
        children: <Widget>[
          TextFormField(
            initialValue: newName,
            onChanged: (name) {
              newName = name;
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
    final bark = Provider.of<Bark>(context);
    String barkName = bark.name;
    return Card(
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
                renameBark(bark);
              } catch (e) {
                showErrorDialog(context, e);
              }
            },
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 18),
                children: [
                  WidgetSpan(
                    child: Text(barkName),
                  ),
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Icon(Icons.edit, color: Colors.blueGrey, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // subtitle: Text(pet.name),
          trailing: IconButton(
            onPressed: () {
              deleteBark(bark);
            },
            icon: Icon(Icons.delete, color: Colors.redAccent, size: 30),
          ),
        ),
      ),
    );
  }
}
