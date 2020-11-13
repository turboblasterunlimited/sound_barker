import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';

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
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: SvgPicture.asset(
                "assets/logos/K9_logotype.svg",
                // width: 100,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Padding(
              //     child:
              //         Image.asset("assets/logos/K9_logotype.png", width: 200),
              //     padding: EdgeInsets.all(20)),
              Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: SpinKitWave(
                  // color: Theme.of(context).primaryColor,
                  color: Colors.blue,
                  size: 100,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: Center(
                  child: Text(
                    // toString incase null
                    widget.messageText.toString(),
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
        ],
      ),
    );
  }
}
