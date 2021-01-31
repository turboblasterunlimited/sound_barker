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
        SizedBox(
          height: MediaQuery.of(context).size.height / 4,
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RawMaterialButton(
                  onPressed: currentActivity.setPreviousSubStep,
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
                  onPressed: currentActivity.setNextSubStep,
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
          ),
        ),
      ],
    );
  }
}
