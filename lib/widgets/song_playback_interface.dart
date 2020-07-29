import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// cardCreationSubStep.isSix
class SongPlaybackInterface extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentActivity =
        Provider.of<CurrentActivity>(context, listen: false);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Text("SOUNDS GOOD?",
              style: TextStyle(
                  fontSize: 20, color: Theme.of(context).primaryColor)),
        ),
        Padding(
          padding: EdgeInsets.all(20),
        ),
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 130,
              width: 150,
              child: Column(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    iconSize: 70,
                    onPressed: currentActivity.setPreviousSubStep,
                  ),
                  Text("Back", style: TextStyle(fontSize: 16))
                ],
              ),
            ),
            SizedBox(
              height: 130,
              width: 150,
              child: Column(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    iconSize: 70,
                    onPressed: currentActivity.setNextSubStep,
                  ),
                  Text("Next", style: TextStyle(fontSize: 16))
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
