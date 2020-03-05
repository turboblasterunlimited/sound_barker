import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pictures.dart';

class PictureCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final picture = Provider.of<Picture>(context, listen: false);
    final pictures = Provider.of<Pictures>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: Stack(
          children: <Widget>[
            RawMaterialButton(
              onPressed: () {
                print("Clicked on delete...");
              },
              child: Icon(
                Icons.delete,
                color: Colors.black38,
                size: 10,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor: Colors.redAccent[200],
            ),
            GestureDetector(
              onTap: () {
                print("Clicked on image...");
                // Mount this picture to the singing image screen.
              },
              child: Image.asset(
                picture.filePath,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
