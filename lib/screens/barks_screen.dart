import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:io';
// import 'dart:typed_data' show Uint8List;
import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart';


import '../providers/barks.dart';

// Cloud Storage
import 'package:gcloud/storage.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

// import '../widgets/barks_grid.dart';

enum t_MEDIA {
  FILE,
  BUFFER,
  ASSET,
  STREAM,
}

class BarksScreen extends StatefulWidget {
  static const routeName = 'bark-screen';

  @override
  _BarksScreenState createState() => _BarksScreenState();
}

class _BarksScreenState extends State<BarksScreen> {
  String uniqueFileName;
  String filePath;
  var uuid = Uuid();
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

  void uploadFile() {
    rootBundle
        .loadString('credentials/gcloud_credentials.json')
        .then((credData) {
      var credentials = new auth.ServiceAccountCredentials.fromJson(credData);
      List<String> scopes = []..addAll(Storage.SCOPES);

      auth
          .clientViaServiceAccount(credentials, scopes)
          .then((auth.AutoRefreshingAuthClient client) {
        var storage = new Storage(client, 'songbarker');
        Bucket bucket = storage.bucket('song_barker_sequences');
        new File(this.filePath).openRead().pipe(bucket.write("${this.uniqueFileName}.aac"));
      });
    });
  }

  void startRecorder() async {
    try {
      // String path = await flutterSound.startRecorder
      // (
      //   paths[_codec.index],
      //   codec: _codec,
      //   sampleRate: 16000,
      //   bitRate: 16000,
      //   numChannels: 1,
      //   androidAudioSource: AndroidAudioSource.MIC,
      // );
      this.uniqueFileName = uuid.v4();
      Directory tempDir = await getTemporaryDirectory();
      File outputFile = File('${tempDir.path}/${this.uniqueFileName}.aac');
      String path = await flutterSound.startRecorder(
        uri: outputFile.path,
        codec: _codec,
      );
      // String path = await flutterSound.startRecorder(
      //   codec: _codec,
      // );
      print('startRecorder: $path');

      _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.currentPosition.toInt(),
            isUtc: true);
        String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);

        this.setState(() {
          this._recorderTxt = txt.substring(0, 8);
          filePath = outputFile.path;
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
        this._path[_codec.index] = path;
      });
    } catch (err) {
      print('startRecorder error: $err');
      setState(() {
        this._isRecording = false;
      });
    }
  }

  void stopRecorder() async {
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
    this.setState(() {
      this._isRecording = false;
      uploadFile();
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Song Barker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Ink(
                    height: 80,
                    width: 80,
                    decoration: const ShapeDecoration(
                      color: Colors.redAccent,
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                      color: Colors.black38,
                      icon: Icon(Icons.mic),
                      iconSize: 50,
                      onPressed: onStartRecorderPressed(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                    // child: BarksGrid(),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
