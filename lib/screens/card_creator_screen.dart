import 'package:flutter/material.dart';

import 'package:song_barker/widgets/singing_image.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Add a personal message?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: <Widget>[
          SingingImage(widget.picture),
          Visibility(
            visible: !_messageIsDone,
            child: MessageCreator(updateMessageFilePathCallback),
          ),
          Visibility(
            visible: _messageIsDone,
            child: Expanded(
              child: Column(),
            ),
            // child: CardDecorator(),

          ),
        ],
      ),
    );
  }
}