import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';

import '../providers/pictures.dart';
import 'main_screen.dart';
import '../providers/image_controller.dart';

class ConfirmPictureScreen extends StatelessWidget {
  final Picture newPicture;
  const ConfirmPictureScreen(this.newPicture);

  @override
  Widget build(BuildContext context) {
    Pictures pictures = Provider.of<Pictures>(context, listen: false);
    ImageController imageController = Provider.of<ImageController>(context);
    String _pictureName = "";

    void _submitPicture(context) {
      newPicture.name = _pictureName;
      newPicture.uploadPictureAndSaveToServer();
      pictures.add(newPicture);
      pictures.mountedPicture = newPicture;
      imageController.loadImage(newPicture);

      Navigator.popUntil(
        context,
        ModalRoute.withName(Navigator.defaultRouteName),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Song Barker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Image.file(File(newPicture.filePath)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    style: TextStyle(fontSize: 30),
                    textAlign: TextAlign.center,
                    autofocus: true,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Give it a name!';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _pictureName = value;
                    },
                    onFieldSubmitted: (_) {
                      _submitPicture(context);
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Give it a name',
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        RawMaterialButton(
                          onPressed: () {
                            _submitPicture(context);
                          },
                          child: Icon(
                            Icons.thumb_up,
                            color: Colors.black38,
                            size: 40,
                          ),
                          shape: CircleBorder(),
                          elevation: 2.0,
                          fillColor: Colors.green,
                          padding: const EdgeInsets.all(15.0),
                        ),
                        RawMaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.thumb_down,
                            color: Colors.black38,
                            size: 40,
                          ),
                          shape: CircleBorder(),
                          elevation: 2.0,
                          fillColor: Colors.red,
                          padding: const EdgeInsets.all(15.0),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
