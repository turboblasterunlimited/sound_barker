import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';
import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';
// import 'package:path_provider/path_provider.dart';

import '../providers/barks.dart';
import '../providers/pets.dart';

enum t_MEDIA {
  FILE,
  BUFFER,
  ASSET,
  STREAM,
}

class RecordButton extends StatefulWidget {
  static const routeName = 'bark-screen';

  @override
  _RecordButtonState createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  String filePath;
  bool _isRecording = false;
  List<String> _path = [null, null, null, null, null, null, null];
  StreamSubscription _recorderSubscription;
  StreamSubscription _dbPeakSubscription;
  StreamSubscription _playerSubscription;
  FlutterSound flutterSound;

  String _recorderTxt = '00:00:00';
  String _playerTxt = '00:00:00';
  double _dbLevel;

  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;
  t_MEDIA _media = t_MEDIA.FILE;
  t_CODEC _codec = t_CODEC.CODEC_AAC;

  @override
  void initState() {
    super.initState();
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);
    flutterSound.setDbPeakLevelUpdate(0.8);
    flutterSound.setDbLevelEnabled(true);
    initializeDateFormatting();
  }

  void startRecorder() async {
    try {
      this.filePath = await flutterSound.startRecorder(
        codec: _codec,
      );
      print('startRecorder: $filePath');

      _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.currentPosition.toInt(),
            isUtc: true);
        String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);

        setState(() {
          this._recorderTxt = txt.substring(0, 8);
        });
      });
      _dbPeakSubscription =
          flutterSound.onRecorderDbPeakChanged.listen((value) {
        print("got update -> $value");
        setState(() {
          this._dbLevel = value;
        });
      });

      this.setState(() {
        this._isRecording = true;
        this._path[_codec.index] = filePath;
      });
    } catch (err) {
      print('startRecorder error: $err');
      setState(() {
        this._isRecording = false;
      });
    }
  }

  void stopRecorder() async {
    setState(() {
      this._isRecording = false;
    });
    final pets = Provider.of<Pets>(context, listen: false);
    String petId;
    String petName = 'Peter Barker';
    Pet pet;

    try {
      String result = await flutterSound.stopRecorder();
      print('stopRecorder: $result');
      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }
      if (_dbPeakSubscription != null) {
        _dbPeakSubscription.cancel();
        _dbPeakSubscription = null;
      }
    } catch (err) {
      print('stopRecorder error: $err');
    }
    await showDialog<Null>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Who made that noise?'),
        contentPadding: EdgeInsets.all(10),
        titlePadding: EdgeInsets.all(10),
        children: <Widget>[
          Visibility(
            visible: pets.all.length != 0,
            child: RadioButtonGroup(
              labels: pets.all.map((pet) => pet.name).toList(),
              onSelected: (String selected) {
                petId = pets.allPetNameIdPairs()[selected];
                petName = selected;
                Navigator.of(ctx).pop();
              },
            ),
          ),
          TextFormField(
            initialValue: petName,
            decoration: InputDecoration(
                labelText:
                    pets.all.length == 0 ? 'Who was recorded?' : 'Someone else?'),
            onFieldSubmitted: (name) {
              pet = Pet(name: name);
              pets.all.add(pet);
              petName = name;
              petId = pet.id;
              Navigator.of(ctx).pop();
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'Please provide a name.';
              }
              return null;
            },
          )
        ],
      ),
    );
    Bark bark;
    print("Checkpoint!!!!!!");
    // try {
      bark = Bark(petId: petId, name: petName, filePath: filePath);
      await bark.uploadBark();
    // } catch (error) {
      // print(error);
      // return;
    // }
    setState(() {
      // Must ALWAYS add bark to both pet and Barks.all
      pet.addBark(bark);
      Provider.of<Barks>(context, listen: false).addBark(bark);
    });
  }

  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  onStartRecorderPressed() {
    if (_media == t_MEDIA.ASSET || _media == t_MEDIA.BUFFER) return null;
    if (flutterSound.audioState == t_AUDIO_STATE.IS_RECORDING)
      return stopRecorder;

    return flutterSound.audioState == t_AUDIO_STATE.IS_STOPPED
        ? startRecorder
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RawMaterialButton(
          onPressed: onStartRecorderPressed(),
          child: Icon(
            Icons.mic,
            color: Colors.black38,
            size: 50,
          ),
          shape: CircleBorder(),
          elevation: 2.0,
          fillColor: this._isRecording ? Colors.redAccent[200] : Colors.white,
          padding: const EdgeInsets.all(15.0),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            'Record some noises!',
            style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }
}
