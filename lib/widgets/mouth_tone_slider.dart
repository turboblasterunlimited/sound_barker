import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MouthToneSlider extends StatefulWidget {
  @override
  _MouthToneSliderState createState() => _MouthToneSliderState();
}

class _MouthToneSliderState extends State<MouthToneSlider> {
  KaraokeCard card;
  CurrentActivity currentActivity;
  // final pinkMouthTone = [0.5686274509, 0.39607843137, 0.43137254902];
  // List<double> mouthTone = [0.5686274509, 0.39607843137, 0.43137254902];
  List<int> pinkMouthTone = [145, 101, 110];
  List<int> mouthTone = [145, 101, 110];
  ImageController imageController;

  @override
  Widget build(BuildContext context) {
    card = Provider.of<KaraokeCards>(context).currentCard;
    currentActivity = Provider.of<CurrentActivity>(context);
    imageController = Provider.of<ImageController>(context);

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ClipOval(
            child: Material(
              color: Colors.black,
              child: InkWell(
                child: SizedBox(width: 56, height: 56),
              ),
            ),
          ),
          Slider.adaptive(
            value: 0.5,
            min: 0,
            max: 1,
            onChanged: (val) {
              setState(() {
                pinkMouthTone.asMap().forEach((i, val) {
                  mouthTone[i] = val;
                });
              });
            },
          ),
          ClipOval(
            child: Material(
              color: Color(0xff91656e),
              child: InkWell(
                child: SizedBox(width: 56, height: 56),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
