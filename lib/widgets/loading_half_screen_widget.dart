import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingHalfScreenWidget extends StatefulWidget {
  String message;

  LoadingHalfScreenWidget(this.message);
  @override
  _LoadingHalfScreenWidget createState() => _LoadingHalfScreenWidget();
}

class _LoadingHalfScreenWidget extends State<LoadingHalfScreenWidget> {
  Widget build(BuildContext context) {

    // Must be child of COLUMN or ROW widget and parent of COLUMN or ROW must have fixed height.
    return Expanded(
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
