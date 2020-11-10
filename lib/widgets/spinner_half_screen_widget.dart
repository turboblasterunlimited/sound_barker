import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SpinnerHalfScreenWidget extends StatefulWidget {
  String message;

  SpinnerHalfScreenWidget(this.message);

  @override
  _SpinnerHalfScreenWidget createState() => _SpinnerHalfScreenWidget();
}

class _SpinnerHalfScreenWidget extends State<SpinnerHalfScreenWidget> {
  Widget build(BuildContext context) {

    // Must be child of COLUMN or ROW widget
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SpinKitWave(
            color: Colors.blue,
            size: 100,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: Center(
              child: Text(
                // toString incase null
                widget.message ?? "Loading...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 25,
                ),
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}
