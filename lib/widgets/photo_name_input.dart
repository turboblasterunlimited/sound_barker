import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';

import '../providers/pictures.dart';

class PhotoNameInput extends StatefulWidget {
  final Picture picture;
  Function updateNameCallback;

  PhotoNameInput(this.picture, this.updateNameCallback);

  @override
  _PhotoNameInputState createState() => _PhotoNameInputState();
}

class _PhotoNameInputState extends State<PhotoNameInput> {
  KaraokeCards cards;
  final _textFormFocus = FocusNode();
  final _textController = TextEditingController();
  double textWidth = 150;
  double maxTextWidth;

  void handleNameChange(name) {
    if (name != "") widget.updateNameCallback(name);
    FocusScope.of(context).unfocus();
    SystemChrome.restoreSystemUIOverlays();
  }

  double _getTextInputWidth() {
    double newWidth = _textController.text.length * 5.1 + 150;
    return newWidth > maxTextWidth ? maxTextWidth : newWidth;
  }

  @override
  Widget build(BuildContext context) {
    cards = Provider.of<KaraokeCards>(context, listen: false);
    maxTextWidth = MediaQuery.of(context).size.width / 2;
    _textController.text = widget.picture.name;

    return Expanded(
      child: Row(
        children: [
          Spacer(),
          Container(
            width: _getTextInputWidth(),
            child: TextFormField(
              // onChanged: (text) => _updateContainerSize(text),
              controller: _textController,
              maxLength: 20,
              focusNode: _textFormFocus,
              autofocus: widget.picture.isNamed ? false : true,
              enabled: !widget.picture.isStock,
              style: TextStyle(color: Colors.grey[600], fontSize: 20),
              textAlign: cards.currentPictureIsStock
                  ? TextAlign.center
                  : TextAlign.right,
              decoration: InputDecoration(
                  // hintText: widget.picture.name,
                  counterText: "",
                  suffixIcon: widget.picture.isStock
                      ? null
                      : Icon(LineAwesomeIcons.edit),
                  border: InputBorder.none),
              onFieldSubmitted: (val) => handleNameChange(val),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
