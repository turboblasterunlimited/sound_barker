import 'dart:convert';
import 'dart:io';

import 'package:K9_Karaoke/tools/amplitude_extractor.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:K9_Karaoke/tools/ffmpeg.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'package:K9_Karaoke/widgets/card_decorator.dart';
import 'package:K9_Karaoke/widgets/card_decorator_canvas.dart';
import 'package:path_provider/path_provider.dart';

import 'package:K9_Karaoke/widgets/singing_image.dart';
import '../providers/songs.dart';
import '../providers/pictures.dart';
import '../widgets/message_creator.dart';

enum t_MEDIA {
  FILE,
  BUFFER,
  ASSET,
  STREAM,
}

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
  String cardAudioFilePath = myAppStoragePath + "/message_song_audio.aac";
  List cardAmplitudes;

  Future<void> mergeMessageWithSong(String messageFilePath) async {
    await FFMpeg.process.execute(
        'ffmpeg -i "concat:$messageFilePath|${widget.song.filePath}" -c copy $cardAudioFilePath');
    cardAmplitudes = await AmplitudeExtractor.getAmplitudes(cardAudioFilePath);
  }

  void addMessageCallback([String messageFilePath]) async {
    setState(() async {
      _messageIsDone = true;
      if (messageFilePath != null)
        await mergeMessageWithSong(messageFilePath);
      else {
        // no message added
        cardAudioFilePath = widget.song.filePath;
        cardAmplitudes = await AmplitudeExtractor.fileToList(widget.song.amplitudesPath);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ImageController>(context, listen: false).resetReadyInit();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _messageIsDone ? "Decorate it!" : 'Add a personal message?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1 / 1,
            child: Stack(
              children: <Widget>[
                SingingImage(
                  picture: widget.picture,
                  visibilityKey: "cardCreation",
                ),
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
            child: CardDecorator(),
          ),
        ],
      ),
    );
  }
}
