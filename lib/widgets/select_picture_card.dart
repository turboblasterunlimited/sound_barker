import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_barker/providers/image_controller.dart';
import 'dart:io';

import '../providers/pictures.dart';

class SelectPictureCard extends StatefulWidget {
  final int index;
  final Picture picture;
  final Pictures pictures;
  final Function setPictureId;
  final String selectedPictureId;
  SelectPictureCard(this.index, this.picture, this.pictures, this.setPictureId, this.selectedPictureId);

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
    return Container(
      decoration: BoxDecoration(
        border: isSelected ? Border.all(color: Colors.blueAccent, width: 10) : Border.all(width: 0, color: Colors.transparent),
      ),
      child: ClipRRect(

        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          child: GestureDetector(
            onTap: () {
              widget.setPictureId(widget.picture.fileId);
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
    );
  }
}
