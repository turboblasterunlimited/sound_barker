import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';
import 'dart:io';

import '../providers/barks.dart';
import '../providers/pets.dart';
import '../providers/pet_image_controller.dart';
import '../functions/error_dialog.dart';

class BarkPlaybackCard extends StatefulWidget {
  final int index;
  final Bark bark;
  BarkPlaybackCard(this.index, this.bark);

  @override
  _BarkPlaybackCardState createState() => _BarkPlaybackCardState();
}

class _BarkPlaybackCardState extends State<BarkPlaybackCard> {
  FlutterSound flutterSound;
  StreamSubscription _playerSubscription;

  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);
    flutterSound.setDbPeakLevelUpdate(0.8);
    flutterSound.setDbLevelEnabled(true);
  }

  @override
  void dispose() {
    flutterSound.stopPlayer();
    super.dispose();
  }

  void playBark() async {
    Provider.of<PetImageController>(context, listen: false).triggerBark();
    String path = widget.bark.filePath;
    //print('playing bark!');
    //print(path);
    if (File(path).exists() == null) {
      //print("No audio file found at: $path");
      return;
    }
    try {
      path = await flutterSound.startPlayer(path);
      await flutterSound.setVolume(1.0);

      _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
        if (e != null) {
          this.setState(() {
            this._isPlaying = true;
          });
        }
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  void deleteBark(bark, pet) async {
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
              onPressed: () async {
                try {
                  await bark.deleteFromServer();
                } catch (e) {
                  showErrorDialog(context, e);
                  return;
                } finally {
                  Navigator.of(ctx).pop();
                }
                pet.removeBark(bark);
                barks.removeBark(bark);
              })
        ],
      ),
    );
  }

  void renameBark(bark, pet) async {
    String newName = bark.name == null ? "${pet.name}'s bark" : bark.name;
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
            onFieldSubmitted: (name) {
              try {
                bark.rename(name);
              } catch (e) {
                showErrorDialog(context, e);
              }
              Navigator.of(ctx).pop();
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
              try {
                bark.rename(newName);
              } catch (e) {
                showErrorDialog(context, e);
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bark = Provider.of<Bark>(context, listen: false);
    final pet = Provider.of<Pets>(context, listen: false).getById(bark.petId);
    final String placeholderName =
        "${pet.name}_${(widget.index + 1).toString()}";

    String barkName = bark.name == null ? placeholderName : bark.name;
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
              // Playback bark.
              playBark();
            },
            icon: Icon(Icons.play_arrow, color: Colors.black, size: 40),
          ),
          title: GestureDetector(
            onTap: () {
              try {
                renameBark(bark, pet);
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
          subtitle: Text(pet.name),
          trailing: IconButton(
            onPressed: () {
              deleteBark(bark, pet);
            },
            icon: Icon(Icons.delete, color: Colors.redAccent, size: 30),
          ),
        ),
      ),
    );
  }
}
