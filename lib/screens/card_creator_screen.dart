import 'dart:io';
import 'package:K9_Karaoke/providers/sound_controller.dart';
import 'package:K9_Karaoke/tools/amplitude_extractor.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:K9_Karaoke/tools/ffmpeg.dart';
import 'package:flutter/material.dart';

import 'package:K9_Karaoke/widgets/card_decorator_interface.dart';
import 'package:K9_Karaoke/widgets/card_decorator_canvas.dart';
import 'package:K9_Karaoke/widgets/singing_image.dart';
import 'package:uuid/uuid.dart';
import '../providers/songs.dart';
import '../providers/pictures.dart';
import '../widgets/message_creator.dart';

class CardCreatorScreen extends StatefulWidget {
  static const routeName = 'record-message-screen';
  Song song;
  Picture picture;
  CardCreatorScreen(this.song, this.picture);

  @override
  _CardCreatorScreenState createState() => _CardCreatorScreenState();
}

class _CardCreatorScreenState extends State<CardCreatorScreen> {
  bool _messageIsDone = false;
  String cardAudioId = Uuid().v4();
  String cardAudioFilePath;
  List cardAmplitudes;
  SoundController soundController;

  initState() {
    cardAudioFilePath = "$myAppStoragePath/$cardAudioId.aac";
    super.initState();
  }

  Future<List> _mergeMessageWithSong(String messageFilePath) async {
    // delete old files
    final cardAudioFile = File(cardAudioFilePath);
    final tempFile = File("$myAppStoragePath/tempFile.wav");
    if (cardAudioFile.existsSync()) cardAudioFile.deleteSync();
    // concat and save card audio file
    await FFMpeg.process.execute(
        '-i "concat:$messageFilePath|${widget.song.filePath}" -c copy ${tempFile.path}');
    await FFMpeg.process.execute('-i ${tempFile.path} $cardAudioFilePath');
    if (tempFile.existsSync()) tempFile.deleteSync();
    // concat and return amplitudes
    List messageAmplitudes =
        await AmplitudeExtractor.getAmplitudes(messageFilePath);
    List songAmplitudes =
        await AmplitudeExtractor.fileToList(widget.song.amplitudesPath);
    return messageAmplitudes + songAmplitudes;
  }

  void addMessageCallback([String messageFilePath]) async {
    List amplitudes;
    if (messageFilePath != null) {
      // message added
      amplitudes = await _mergeMessageWithSong(messageFilePath);
      setState(() {
      cardAmplitudes = amplitudes;
      _messageIsDone = true;
    });
    } else {
      // no message added
      amplitudes =
          await AmplitudeExtractor.fileToList(widget.song.amplitudesPath);
      setState(() {
        cardAudioId = widget.song.fileId;
        cardAudioFilePath = widget.song.filePath;
        cardAmplitudes = amplitudes;
        _messageIsDone = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _messageIsDone ? "Decorate it!" : 'Add a personal message?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        // BACK ARROW
        leading: RawMaterialButton(
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 22,
          ),
          onPressed: () {
            setState(() {
              if (_messageIsDone)
                setState(() => _messageIsDone = false);
              else
                Navigator.of(context).pop();
            });
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1 / 1,
            child: Stack(
              children: <Widget>[
                
                CardDecoratorCanvas(),
              ],
            ),
          ),
          Visibility(
            visible: !_messageIsDone,
            child: MessageCreator(addMessageCallback),
          ),
          Visibility(
            visible: _messageIsDone,
            child: CardDecoratorInterface(cardAudioFilePath, cardAudioId, cardAmplitudes, widget.picture.fileId),
          ),
        ],
      ),
    );
  }
}
