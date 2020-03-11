import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_barker/providers/image_controller.dart';
import 'dart:io';

import '../providers/pictures.dart';

class PictureCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final picture = Provider.of<Picture>(context, listen: false);
    final pictures = Provider.of<Pictures>(context, listen: false);
    final ImageController imageController =
        Provider.of<ImageController>(context);
    
    // print(myAppStoragePath);
    // Directory(myAppStoragePath).list().forEach((item)=> {print(item.path)});
    // print(picture.name + "!!!!!!!!! ");
    // print(File(picture.filePath).existsSync());

    return Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          child: Stack(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  print("Clicked on image...");
                  imageController.loadImage(picture);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(
                    File(picture.filePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: -25,
                top: -5,
                child: RawMaterialButton(
                  onPressed: () {
                    pictures.remove(picture);
                  },
                  child: Icon(
                    Icons.delete,
                    color: Colors.black38,
                    size: 20,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
