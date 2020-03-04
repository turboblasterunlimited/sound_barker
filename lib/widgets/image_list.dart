import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:song_barker/widgets/song_playback_card.dart';
import '../providers/images.dart';

class ImageList extends StatefulWidget {
  @override
  _ImageListState createState() => _ImageListState();
}

class _ImageListState extends State<ImageList> {
  @override
  Widget build(BuildContext context) {
    Images images = Provider.of<Images>(context);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RawMaterialButton(
                onPressed: () {
                  // uploadImage(),
                },
                child: Icon(
                  Icons.image,
                  color: Colors.black38,
                  size: 40,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.white,
                padding: const EdgeInsets.all(15.0),
              ),
              RawMaterialButton(
                onPressed: () {
                  // uploadImage(),
                },
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.black38,
                  size: 40,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.white,
                padding: const EdgeInsets.all(15.0),
              ),
            ],
          ),
        ),
        // Expanded(
        // child: ListView.builder(
        //   padding: const EdgeInsets.all(10),
        //   itemCount: images.all.length,
        //   itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        //     value: images.all[i],
        //     child: ImageCard(i, images.all[i]),
        //   ),
        // ),
        // ),
      ],
    );
  }
}
