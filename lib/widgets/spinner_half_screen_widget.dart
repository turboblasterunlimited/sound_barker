import 'package:K9_Karaoke/providers/spinner_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class SpinnerHalfScreenWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    final spinnerState = Provider.of<SpinnerState>(context);
    return Expanded(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SpinKitWave(
            color: Colors.blue,
            size: 100,
          ),
          Center(
            child: Text(
              spinnerState.loadingMessage,
            ),
          ),
        ],
      ),
    );
  }
}
