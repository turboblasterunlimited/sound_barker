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
  bool _firstBuild = true;

  double get _nameRightPadding {
    int nameLength = widget.picture.name.length ?? 0;
    return 45.0 - (nameLength * 3);
  }

  void handleNameChange(name) {
    if (name != "") widget.updateNameCallback(name);
    FocusScope.of(context).unfocus();
    SystemChrome.restoreSystemUIOverlays();
  }

  @override
  Widget build(BuildContext context) {
    cards = Provider.of<KaraokeCards>(context, listen: false);

    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: _nameRightPadding),
        child: TextFormField(
          focusNode: _textFormFocus,
          autofocus: widget.picture.isNamed ? false : true,
          // controller: _textController,

          enabled: !widget.picture.isStock,
          style: TextStyle(color: Colors.grey[600], fontSize: 20),
          textAlign:
              cards.currentPictureIsStock ? TextAlign.center : TextAlign.right,
          decoration: InputDecoration(
              hintText: widget.picture.name,
              counterText: "",
              suffixIcon:
                  widget.picture.isStock ? null : Icon(LineAwesomeIcons.edit),
              border: InputBorder.none),
          onFieldSubmitted: (val) => handleNameChange(val),
        ),
      ),
    );
  }
}
