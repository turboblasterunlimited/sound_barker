import 'package:K9_Karaoke/components/triangular_slider_track_shape.dart';
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
  List<int> currentMouthColor;
  double mouthColorSliderValue = 0.0;

  // LIPS
  List<int> currentLipColor;
  double lipColorSliderValue = 0.0;

  double currentLipThickness;

  @override
  void dispose() {
    imageController.cancelMouthOpenAndClose();
    super.dispose();
  }

  List<int> interpolate(double sliderVal) {
    List<int> result = [0, 0, 0];
    Color color = Color.lerp(
        Colors.black, Color.fromRGBO(145, 101, 110, 1.0), sliderVal / 3.0);
    result[0] = color.red;
    result[1] = color.green;
    result[2] = color.blue;
    return result;
  }

  List<double> colorToDecimal(List<int> currentColor) {
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
    card.picture.updateMouth(colorToDecimal(currentMouthColor),
        colorToDecimal(currentLipColor), currentLipThickness);
    currentActivity.setCardCreationStep(CardCreationSteps.song);
  }

  List get sliderMouthTone {
    if (mouthColorSliderValue > 2) {
      return fleshMouthTone;
    } else if (mouthColorSliderValue > 1) {
      return pinkMouthTone;
    } else if (mouthColorSliderValue >= 0) {
      return redMouthTone;
    }
    return fleshMouthTone;
  }

  List get sliderLipTone {
    if (lipColorSliderValue > 2) {
      return fleshMouthTone;
    } else if (lipColorSliderValue > 1) {
      return pinkMouthTone;
    } else if (lipColorSliderValue >= 0) {
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

  void setLips(double val) {
    setState(() {
      currentLipThickness = val;
    });
    imageController.setLipThickness(currentLipThickness);
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
        InterfaceTitleNav(title: "MOUTH & LIPS", backCallback: backCallback),
        // MOUTH
        Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Text("Mouth Color"),
            ),
            Row(
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
                  value: mouthColorSliderValue,
                  min: 0,
                  max: 3,
                  onChanged: (double sliderVal) {
                    setState(() {
                      mouthColorSliderValue = sliderVal;

                      // jmf -- changed to use interpolate
                      currentMouthColor = interpolate(sliderVal);
                    });
                    imageController
                        .setMouthColor(colorToDecimal(currentMouthColor));
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
          ],
        ),

        // LIPS THICKNESS
        Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Text("Lip Thickness"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                    child: Icon(
                      Icons.close,
                      size: 30,
                      color: Theme.of(context).errorColor,
                    ),
                    onTap: () => setLips(0)),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbColor: Colors.blue[700],
                    trackHeight: 12,
                    trackShape: TriangularSliderTrackShape(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                  child: Slider(
                    value: currentLipThickness,
                    min: 0,
                    max: 0.4,
                    onChanged: (double sliderVal) {
                      setLips(sliderVal);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),

        // LIPS COLOR
        Opacity(
          opacity: currentLipThickness > 0 ? 1 : 0.5,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Text("Lip Color"),
              ),
              Row(
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
                    onChanged: currentLipThickness > 0
                        ? (double sliderVal) {
                            setState(() {
                              lipColorSliderValue = sliderVal;
                              currentLipColor = interpolate(sliderVal);
                            });

                            imageController
                                .setLipColor(colorToDecimal(currentLipColor));
                          }
                        : null,
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
            ],
          ),
        ),
        Center(
          child: RawMaterialButton(
            onPressed: handleSubmitButton,
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 18,
            ),
            constraints: BoxConstraints(minHeight: 24.0, minWidth: 88.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            elevation: 2.0,
            fillColor: Theme.of(context).primaryColor,
            // padding: const EdgeInsets.symmetric(horizontal: 40.0),
          ),
        ),
      ],
    );
  }
}
