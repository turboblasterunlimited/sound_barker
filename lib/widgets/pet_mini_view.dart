import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/Pet.dart';
import '../providers/User.dart';


class PetMiniView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pet = Provider.of<Pet>(context, listen: false);
    return Column(
      children: <Widget>[
        Image.network(pet.imageUrl),
        Text(
          pet.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        RaisedButton(
          color: Colors.redAccent,
          elevation: 0,
          onPressed: () {
            // Playback bark.
            print(pet.imageUrl);
            () {};
          },
          child: Icon(Icons.play_arrow, color: Colors.purple, size: 30),
        ),
      ],
    );
  }
}
