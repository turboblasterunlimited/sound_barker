import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'package:K9_Karaoke/providers/sound_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// cardCreationSubStep.isSix
class SongPlaybackInterface extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentActivity =
        Provider.of<CurrentActivity>(context, listen: false);
    final soundController =
        Provider.of<SoundController>(context, listen: false);
    final imageController =
        Provider.of<ImageController>(context, listen: false);

    _handleButtonPress(Function callback) {
      soundController.stopPlayer();
      imageController.stopAnimation();
      callback();
    }

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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RawMaterialButton(
              onPressed: () =>
                  _handleButtonPress(currentActivity.setPreviousSubStep),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 40,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              elevation: 2.0,
              fillColor: Theme.of(context).errorColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 2),
            ),
            Padding(
              padding: EdgeInsets.all(10),
            ),
            RawMaterialButton(
              onPressed: () =>
                  _handleButtonPress(currentActivity.setNextSubStep),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 40,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              elevation: 2.0,
              fillColor: Theme.of(context).primaryColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 2),
            ),
          ],
        ),
      ],
    );
  }
}