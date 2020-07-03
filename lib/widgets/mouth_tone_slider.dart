import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/screens/set_picture_coordinates_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MouthToneSlider extends StatefulWidget {
  @override
  _MouthToneSliderState createState() => _MouthToneSliderState();
}

class _MouthToneSliderState extends State<MouthToneSlider> {
  KaraokeCard card;
  CurrentActivity currentActivity;
  // List<double> mouthToneAsDecimal = [
  //   0.5686274509,
  //   0.39607843137,
  //   0.43137254902
  // ];
  List<int> pinkMouthTone = [145, 101, 110];
  List<int> mouthTone = [145, 101, 110];
  ImageController imageController;
  double _sliderValue = 0.5;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    imageController.mouthOpenAndClose.cancel();
    super.dispose();
  }

  List<double> mouthColorToDecimal() {
    List<double> result = [0.0, 0.0, 0.0];
    mouthTone.asMap().forEach((i, val) {
      result[i] = val / 255;
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    card = Provider.of<KaraokeCards>(context).currentCard;
    currentActivity = Provider.of<CurrentActivity>(context);
    imageController = Provider.of<ImageController>(context);
    imageController.startMouthOpenAndClose();

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
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
                value: _sliderValue,
                min: 0,
                max: 1,
                onChanged: (double sliderVal) {
                  setState(() {
                    _sliderValue = sliderVal;
                    pinkMouthTone.asMap().forEach((i, value) {
                      mouthTone[i] = (value * sliderVal).round();
                    });
                  });
                  imageController.setMouthColor(mouthColorToDecimal());
                },
                onChangeEnd: (_) {},
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
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RawMaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SetPictureCoordinatesScreen(card.picture, isNamed: true, coordinatesSet: true),
                  ),
                );
              },
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
              onPressed: () {
                card.picture.updateMouthColor(mouthColorToDecimal());
                currentActivity.setCardCreationStep(CardCreationSteps.song);
              },
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
