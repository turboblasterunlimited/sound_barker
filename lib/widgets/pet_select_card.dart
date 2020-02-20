import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';
import 'dart:io';

import '../providers/barks.dart';
import '../providers/pets.dart';
import '../providers/songs.dart';

class PetSelectCard extends StatefulWidget {
  final int index;

  PetSelectCard(this.index);

  @override
  _PetSelectCardState createState() => _PetSelectCardState();
}

class _PetSelectCardState extends State<PetSelectCard> {
  @override
  Widget build(BuildContext context) {
    final pet = Provider.of<Pets>(context, listen: false).all[widget.index];

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 3,
      ),
      child: Padding(
        padding: EdgeInsets.all(4),
        child: ListTile(
          leading: Visibility(
            visible: pet.imageUrl != null,
            child: CircleAvatar(
              radius: 40,
              backgroundImage: pet.imageUrl != null
                  ? NetworkImage(pet.imageUrl)
                  : AssetImage('assets/images/smallest_file.jpg'),
            ),
          ),
          title: Text(pet.name),
          // subtitle: Text(pet.name),
          trailing: IconButton(
            color: Colors.blue,
            onPressed: () {
              // Playback bark.
              // selectPet();
            },
            icon: Icon(Icons.add, color: Colors.black, size: 40),
          ),
        ),
      ),
    );
  }
}
