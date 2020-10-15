import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/screens/set_picture_coordinates_screen.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';

int hexOfRGB(int r, int g, int b) {
  r = (r < 0) ? -r : r;
  g = (g < 0) ? -g : g;
  b = (b < 0) ? -b : b;
  r = (r > 255) ? 255 : r;
  g = (g > 255) ? 255 : g;
  b = (b > 255) ? 255 : b;
  var rRad = r.toRadixString(16);
  var gRad = g.toRadixString(16);
  var bRad = b.toRadixString(16);
  rRad = rRad.length == 1 ? "0$rRad" : rRad;
  gRad = gRad.length == 1 ? "0$gRad" : gRad;
  bRad = bRad.length == 1 ? "0$bRad" : bRad;

  print("R: $rRad, G: $gRad, B: $bRad");
  return int.parse('0xff$rRad$gRad$bRad');
}

class MouthToneSlider extends StatefulWidget {
  @override
  _MouthToneSliderState createState() => _MouthToneSliderState();
}

class _MouthToneSliderState extends State<MouthToneSlider> {
  KaraokeCard card;
  CurrentActivity currentActivity;
  // List<double> pinkMouthToneAsDecimal = [
  //   0.5686274509,
  //   0.39607843137,
  //   0.43137254902
  // ];
  //  List<double> redMouthToneAsDecimal = [
  //   0.60392156,
  //   0.12549019607,
  //   0.12549019607
  // ];

  List<int> fleshMouthTone = [145, 101, 110];
  List<int> pinkMouthTone = [145, 55, 55];
  List<int> redMouthTone = [100, 10, 10];

  List<int> startingMouthTone;
  List<int> currentMouthTone;
  ImageController imageController;
  double _sliderValue = 0.0;

  @override
  void dispose() {
    imageController.cancelMouthOpenAndClose();
    super.dispose();
  }

  List<double> mouthColorToDecimal() {
    List<double> result = [0.0, 0.0, 0.0];
    currentMouthTone.asMap().forEach((i, val) {
      result[i] = val / 255;
    });
    return result;
  }

  List<int> mouthColorToInt(List doubles) {
    List<int> result = [0, 0, 0];
    doubles.asMap().forEach((i, val) {
      result[i] = (val * 255).round();
    });
    return result;
  }

  void handleSubmitButton() {
    imageController.cancelMouthOpenAndClose();
    card.picture.updateMouthColor(mouthColorToDecimal());
    currentActivity.setCardCreationStep(CardCreationSteps.song);
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    card = Provider.of<KaraokeCards>(context).current;
    currentActivity = Provider.of<CurrentActivity>(context);
    imageController = Provider.of<ImageController>(context);
    currentMouthTone = mouthColorToInt(card.picture.mouthColor);
  }

  List get sliderMouthTone {
    if (_sliderValue > 2) {
      return fleshMouthTone;
    } else if (_sliderValue > 1) {
      return pinkMouthTone;
    } else if (_sliderValue >= 0) {
      return redMouthTone;
    }
  }

  void backCallback() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SetPictureCoordinatesScreen(card.picture, editing: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Current picture: ${card.picture?.name}");
    imageController.startMouthOpenAndClose();
    print("Building mouth tone slider");
    return Column(
      children: <Widget>[
        interfaceTitleNav(context, "MOUTH TONE", backCallback: backCallback),
        Container(
          padding: const EdgeInsets.only(top: 20.0),
          // height: 100,
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
              Slider(
                value: _sliderValue,
                min: 0,
                max: 3,
                onChanged: (double sliderVal) {
                  setState(() {
                    _sliderValue = sliderVal;
                    sliderMouthTone.asMap().forEach((i, value) {
                      double adjustedVal;
                      if (sliderVal > 2) {
                        adjustedVal = sliderVal - 2;
                      } else if (sliderVal > 1) {
                        adjustedVal = sliderVal - 1;
                      } else if (sliderVal > 0) {
                        adjustedVal = sliderVal;
                      }
                      currentMouthTone[i] = (value * adjustedVal).round();
                    });
                  });
                  imageController.setMouthColor(mouthColorToDecimal());
                },
                onChangeEnd: (_) {},
              ),
              ClipOval(
                child: Material(
                  color: Color(
                    hexOfRGB(
                      sliderMouthTone[0],
                      sliderMouthTone[1],
                      sliderMouthTone[2],
                    ),
                  ),
                  child: InkWell(
                    child: SizedBox(width: 56, height: 56),
                  ),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: RawMaterialButton(
            onPressed: handleSubmitButton,
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 30,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            elevation: 2.0,
            fillColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 2),
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 20.0),)
      ],
    );
  }
}
