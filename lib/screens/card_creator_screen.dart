import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'package:K9_Karaoke/widgets/card_decorator.dart';
import 'package:K9_Karaoke/widgets/card_decorator_canvas.dart';

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
  String messageFilePath;

  void updateMessageFilePathCallback([createdMessageFilePath]) {
    setState(() {
      _messageIsDone = true;
      messageFilePath = createdMessageFilePath;
    });
  }

  @override
  Widget build(BuildContext context) {
      Provider.of<ImageController>(context, listen: false).resetReadyInit();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_messageIsDone ? "Decorate it!" : 'Add a personal message?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1 / 1,
            child: Stack(
              children: <Widget>[
                SingingImage(picture: widget.picture, visibilityKey: "cardCreation",),
                CardDecoratorCanvas(),
              ],
            ),
          ),
          Visibility(
            visible: !_messageIsDone,
            child: MessageCreator(updateMessageFilePathCallback),
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
