import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingQuarterScreenWidget extends StatefulWidget {
  final String message;
  final double size;

  LoadingQuarterScreenWidget(this.message, [this.size]);
  @override
  _LoadingQuarterScreenWidget createState() => _LoadingQuarterScreenWidget();
}

class _LoadingQuarterScreenWidget extends State<LoadingQuarterScreenWidget> {
  Widget build(BuildContext context) {
    // Must be child of COLUMN or ROW widget and parent of COLUMN or ROW must have fixed height.
    return
        //Expanded(
        //child:
        Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SpinKitWave(
          color: Colors.blue,
          size: widget.size == null ? 100 : widget.size,
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
      //),
    );
  }
}