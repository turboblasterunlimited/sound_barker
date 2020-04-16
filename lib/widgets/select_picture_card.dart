import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_barker/providers/image_controller.dart';
import 'dart:io';

import '../providers/pictures.dart';

class SelectPictureCard extends StatefulWidget {
  final int index;
  final Picture picture;
  final Pictures pictures;
  final Function setPicture;
  final String selectedPictureId;
  SelectPictureCard(this.index, this.picture, this.pictures, this.setPicture, this.selectedPictureId);

  @override
  _SelectPictureCardState createState() => _SelectPictureCardState();
}

class _SelectPictureCardState extends State<SelectPictureCard> {
  bool isSelected;
  @override
  void initState() {
    super.initState();
    isSelected = widget.picture.fileId == widget.selectedPictureId;
  }

  @override
  void dispose() {
    widget.picture.creationAnimation = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(5)),
          child: Container(
        decoration: BoxDecoration(
          border: isSelected ? Border.all(color: Colors.blueAccent, width: 5) : Border.all(width: 0, color: Colors.transparent),
        ),
        child: ClipRRect(

          borderRadius: BorderRadius.circular(10),
          child: GridTile(
            child: GestureDetector(
              onTap: () {
                widget.setPicture(widget.picture);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(
                  File(widget.picture.filePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
