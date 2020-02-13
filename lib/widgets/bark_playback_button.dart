import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bark.dart';

class BarkPlaybackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bark = Provider.of<Bark>(context, listen: false);

    return Column(
      children: <Widget>[
        Text(
          bark.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        RaisedButton(
          color: Colors.redAccent,
          elevation: 0,
          onPressed: () {
            // Playback bark.
            print(bark.fileUrl);
            () {};
          },
          child: Icon(Icons.play_arrow, color: Colors.purple, size: 30),
        ),
      ],
    );
  }
}
