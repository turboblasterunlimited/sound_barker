import 'package:K9_Karaoke/providers/user.dart';
import 'package:K9_Karaoke/screens/authentication_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class SpinnerWidget extends StatefulWidget {
  String messageText;
  SpinnerWidget([this.messageText]);

  @override
  _SpinnerWidgetState createState() => _SpinnerWidgetState();
}

class _SpinnerWidgetState extends State<SpinnerWidget> {
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.black,
        child: Column(
          children: <Widget>[
            SpinKitWave(
              // color: Theme.of(context).primaryColor,
              color: Colors.black,
              size: 100,
            ),
            Center(
              child: Text(
                // toString incase null
                widget.messageText.toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
