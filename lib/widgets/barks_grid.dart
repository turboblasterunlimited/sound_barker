import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pet.dart';
import './bark_playback_button.dart';
import '../screens/pet_details_screen.dart';

class BarkGrid extends StatelessWidget {
  Widget build(BuildContext context) {
    final pet = Provider.of<Pet>(context);
    final savedBarks = pet.savedBarks;
    return false
        ? Column(
              children: <Widget>[
              RawMaterialButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(PetDetailsScreen.routeName);
                },
                child: Icon(
                  Icons.add,
                  color: Colors.blue,
                  size: 50,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.white,
                padding: const EdgeInsets.all(15.0),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Add a pet!',
                  style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          )
        : GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: savedBarks.length,
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              value: savedBarks[i],
              child: BarkPlaybackButton(),
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
          );
  }
}
