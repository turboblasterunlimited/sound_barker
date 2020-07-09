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
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/backgrounds/menu_background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
                child: Image.asset("assets/logos/K9_logotype.png", width: 200),
                padding: EdgeInsets.all(20)),
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
      ),
    );
  }
}
