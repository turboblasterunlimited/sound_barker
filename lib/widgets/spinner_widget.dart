import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SpinnerWidget extends StatefulWidget {
  String messageText;
  SpinnerWidget([this.messageText]);

  @override
  _SpinnerWidgetState createState() => _SpinnerWidgetState();
}

class _SpinnerWidgetState extends State<SpinnerWidget> {
  Widget build(BuildContext context) {
    return Expanded(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SpinKitWave(
            // color: Theme.of(context).primaryColor,
            color: Colors.blue,
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
    );
  }
}
