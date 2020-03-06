import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';

import '../providers/pictures.dart';

class ConfirmPictureScreen extends StatelessWidget {
  final String _filePath;
  const ConfirmPictureScreen(this._filePath);

  @override
  Widget build(BuildContext context) {
    Pictures pictures = Provider.of<Pictures>(context, listen: false);
    String _pictureName = "";

    void _submitPicture(context) {
      Picture newPicture = Picture(name: _pictureName, filePath: _filePath);
      pictures.add(newPicture);
      int count = 0;
      Navigator.of(context).popUntil((_) => count++ >= 2);
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
            child: Image.file(File(_filePath)),
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
