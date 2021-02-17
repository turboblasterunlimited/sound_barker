import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/screens/set_picture_coordinates_screen.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';
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

  return int.parse('0xff$rRad$gRad$bRad');
}

class MouthInterface extends StatefulWidget {
  @override
  _MouthInterfaceState createState() => _MouthInterfaceState();
}

class _MouthInterfaceState extends State<MouthInterface> {
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

  ImageController imageController;

  List<int> fleshMouthTone = [145, 101, 110];
  List<int> pinkMouthTone = [145, 55, 55];
  List<int> redMouthTone = [100, 10, 10];

  // MOUTH
  List<int> startingMouthColor;
  List<int> currentMouthColor;
  double mouthSliderValue = 0.0;


  // LIPS
  List<int> startingLipColor;
  List<int> currentLipColor;
  double lipColorSliderValue = 0.0;

  double startingLipThickness;
  double currentLipThickness;
  double lipThicknessSliderValue = 0.0; 
  


  @override
  void dispose() {
    imageController.cancelMouthOpenAndClose();
    super.dispose();
  }

  List<double> colorToDecimal(List<int>currentColor) {
    List<double> result = [0.0, 0.0, 0.0];
    currentColor.asMap().forEach((i, val) {
      result[i] = val / 255;
    });
    return result;
  }

  List<int> colorToInt(List doubles) {
    List<int> result = [0, 0, 0];
    doubles.asMap().forEach((i, val) {
      result[i] = (val * 255).round();
    });
    return result;
  }

  void handleSubmitButton() {
    imageController.cancelMouthOpenAndClose();
    card.picture.updateMouth(colorToDecimal(currentMouthColor), colorToDecimal(currentLipColor), currentLipThickness);
    currentActivity.setCardCreationStep(CardCreationSteps.song);
  }

  List get sliderMouthTone {
    if (mouthSliderValue > 2) {
      return fleshMouthTone;
    } else if (mouthSliderValue > 1) {
      return pinkMouthTone;
    } else if (mouthSliderValue >= 0) {
      return redMouthTone;
    }
    return fleshMouthTone;
  }

    List get sliderLipTone {
    if (mouthSliderValue > 2) {
      return fleshMouthTone;
    } else if (mouthSliderValue > 1) {
      return pinkMouthTone;
    } else if (mouthSliderValue >= 0) {
      return redMouthTone;
    }
    return fleshMouthTone;
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
    card ??= Provider.of<KaraokeCards>(context).current;
    currentActivity ??= Provider.of<CurrentActivity>(context);
    imageController ??= Provider.of<ImageController>(context);
    currentMouthColor ??= colorToInt(card.picture.mouthColor);
    currentLipColor ??= colorToInt(card.picture.mouthColor);
    currentLipThickness ??= card.picture.lipThickness;

    print("Current picture: ${card.picture?.name}");
    imageController.startMouthOpenAndClose();
    return Column(
      children: <Widget>[
        InterfaceTitleNav("MOUTH & LIPS", backCallback: backCallback),
        // MOUTH
        Container(
          // height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ClipOval(
                child: Material(
                  color: Colors.black,
                  child: InkWell(
                    child: SizedBox(width: 20, height: 20),
                  ),
                ),
              ),
              Slider(
                value: mouthSliderValue,
                min: 0,
                max: 3,
                onChanged: (double sliderVal) {
                  setState(() {
                    mouthSliderValue = sliderVal;
                    sliderMouthTone.asMap().forEach((i, value) {
                      double adjustedVal;
                      if (sliderVal > 2) {
                        adjustedVal = sliderVal - 2;
                      } else if (sliderVal > 1) {
                        adjustedVal = sliderVal - 1;
                      } else if (sliderVal > 0) {
                        adjustedVal = sliderVal;
                      }
                      currentMouthColor[i] = (value * adjustedVal).round();
                    });
                  });
                  imageController.setMouthColor(colorToDecimal(currentMouthColor));
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
                    child: SizedBox(width: 20, height: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
        // LIPS COLOR
        Container(
          // height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ClipOval(
                child: Material(
                  color: Colors.black,
                  child: InkWell(
                    child: SizedBox(width: 20, height: 20),
                  ),
                ),
              ),
              Slider(
                value: lipColorSliderValue,
                min: 0,
                max: 3,
                onChanged: (double sliderVal) {
                  setState(() {
                    lipColorSliderValue = sliderVal;
                    sliderLipTone.asMap().forEach((i, value) {
                      double adjustedVal;
                      if (sliderVal > 2) {
                        adjustedVal = sliderVal - 2;
                      } else if (sliderVal > 1) {
                        adjustedVal = sliderVal - 1;
                      } else if (sliderVal > 0) {
                        adjustedVal = sliderVal;
                      }
                      currentLipColor[i] = (value * adjustedVal).round();
                    });
                  });
                  imageController.setLipColor(colorToDecimal(currentLipColor));
                },
                onChangeEnd: (_) {},
              ),
              ClipOval(
                child: Material(
                  color: Color(
                    hexOfRGB(
                      sliderLipTone[0],
                      sliderLipTone[1],
                      sliderLipTone[2],
                    ),
                  ),
                  child: InkWell(
                    child: SizedBox(width: 20, height: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
        // LIPS THICKNESS
        Container(
          // height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Thin"),
              Slider(
                value: lipThicknessSliderValue,
                min: 0,
                max: 1,
                onChanged: (double sliderVal) {
                  setState(() {
                    lipThicknessSliderValue = sliderVal;
                    currentLipThickness = num.parse(sliderVal.toStringAsFixed(1));
                  });
                  imageController.setLipThickness(currentLipThickness);
                },
                onChangeEnd: (_) {},
              ),
              Text("Thick"),
            ],
          ),
        ),
        Center(
          child: RawMaterialButton(
            onPressed: handleSubmitButton,
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            elevation: 2.0,
            fillColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 2),
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 10.0),)
      ],
    );
  }
}
