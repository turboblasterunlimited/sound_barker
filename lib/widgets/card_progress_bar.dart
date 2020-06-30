import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

class CardProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
      RawMaterialButton(
        onPressed: () {
          // NAVIGATE
        },
        child: Text('SNAP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        elevation: 2.0,
        fillColor: Theme.of(context).primaryColor,
        // padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2),
      ),
 
      RawMaterialButton(
        onPressed: () {
          // NAVIGATE
        },
        child: Text('SONG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        elevation: 2.0,
        fillColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2),
      ),
      RawMaterialButton(
        onPressed: () {
          // NAVIGATE
        },
        child: Text('SPEAK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        elevation: 2.0,
        fillColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2),
      ),
      RawMaterialButton(
        onPressed: () {
          // NAVIGATE
        },
        child: Text('STYLE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        elevation: 2.0,
        fillColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2),
      ),
    ]);
  }
}
