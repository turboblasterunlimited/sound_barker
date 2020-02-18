import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/barks.dart';
import '../providers/pets.dart';

class BarkPlaybackButton extends StatelessWidget {
  final int index;
  BarkPlaybackButton(this.index);
  @override
  Widget build(BuildContext context) {
    final bark = Provider.of<Bark>(context, listen: false);
    final pet = Provider.of<Pets>(context, listen: false).getById(bark.petId);
    String barkName = bark.name == null ? "${pet.name}_${(index + 1).toString()}" : bark.name;
    return Column(
      children: <Widget>[
        Text(
          barkName,
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
