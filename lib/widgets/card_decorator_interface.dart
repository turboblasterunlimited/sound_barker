import 'package:K9_Karaoke/components/triangular_slider_track_shape.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/sound_controller.dart';
import 'package:K9_Karaoke/services/gcloud.dart';
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/providers/karaoke_card_decorator.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:uuid/uuid.dart';

class CardDecoratorInterface extends StatefulWidget {
  @override
  _CardDecoratorInterfaceState createState() => _CardDecoratorInterfaceState();
}

class _CardDecoratorInterfaceState extends State<CardDecoratorInterface> {
  SoundController soundController;
  KaraokeCardDecorator karaokeCardDecorator;
  ImageController imageController;
  CurrentActivity currentActivity;
  KaraokeCards cards;
  FocusNode focusNode;
  double canvasLength;
  final textController = TextEditingController();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    stopPlayback();
    focusNode.dispose();
    super.dispose();
  }

  void stopPlayback() {
    if (_isPlaying) {
      imageController.stopAnimation();
      soundController.stopPlayer();
      setState(() => _isPlaying = false);
    }
  }

  void playCard() {
    soundController.startPlayer(cards.current.audioFilePath, stopPlayback);
    imageController.mouthTrackSound(amplitudes: cards.current.amplitudes);
    setState(() => _isPlaying = true);
  }

  void saveArtwork() async {
    String decorationImageId = Uuid().v4();
    cards.current.decorationImagePath =
        await karaokeCardDecorator.cardPainter.capturePNG(decorationImageId);
  }

  double iconButtonSize = 35;

  @override
  Widget build(BuildContext context) {
    soundController ??= Provider.of<SoundController>(context);
    imageController ??= Provider.of<ImageController>(context, listen: false);
    karaokeCardDecorator ??= Provider.of<KaraokeCardDecorator>(context);
    canvasLength ??= MediaQuery.of(context).size.width;
    cards ??= Provider.of<KaraokeCards>(context);
    currentActivity ??= Provider.of<CurrentActivity>(context);

    void updateTextColor(color) {
      if (karaokeCardDecorator.isDrawing) return;
      var newTextSpan = TextSpan(
        text: karaokeCardDecorator.allTyping.last.textSpan.text,
        style: TextStyle(color: color),
      );
      karaokeCardDecorator.updateLastTextSpan(newTextSpan);
    }

    return Expanded(
      child: Stack(
        children: <Widget>[
          Opacity(
            opacity: 0,
            child: TextField(
              controller: textController,
              focusNode: focusNode,
              onChanged: (text) {
                print("Text: $text");
                var newTextSpan = TextSpan(
                  text: text,
                  style: TextStyle(color: karaokeCardDecorator.color),
                );
                karaokeCardDecorator.updateLastTextSpan(newTextSpan);
              },
              onSubmitted: (text) {},
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // back, draw, write, sizeSlider, undo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        currentActivity.setPreviousSubStep();
                      },
                      child: Row(children: <Widget>[
                        Icon(LineAwesomeIcons.angle_left, color: Colors.grey),
                        Text(
                          'Back',
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                        ),
                      ]),
                    ),
                    // Drawing button
                    IconButton(
                      color: karaokeCardDecorator.isDrawing
                          ? Colors.blue
                          : Theme.of(context).primaryColor,
                      onPressed: () {
                        focusNode.unfocus();
                        karaokeCardDecorator.startDrawing();
                      },
                      icon: Icon(Icons.edit, size: iconButtonSize),
                    ),
                    // Typing button
                    IconButton(
                      color: karaokeCardDecorator.isTyping
                          ? Colors.blue
                          : Theme.of(context).primaryColor,
                      onPressed: () {
                        focusNode.unfocus();
                        if (karaokeCardDecorator.allTyping.isEmpty) {
                          karaokeCardDecorator.allTyping.add(
                            Typing(
                              TextSpan(
                                text: "",
                                style: TextStyle(
                                    color: karaokeCardDecorator.color,
                                    fontSize: 40),
                              ),
                              Offset(canvasLength / 2, canvasLength - 50),
                            ),
                          );
                          // set color to textSpan that is being edited
                        } else if (karaokeCardDecorator.color !=
                            karaokeCardDecorator
                                .allTyping.last.textSpan.style.color) {
                          karaokeCardDecorator.setColor(karaokeCardDecorator
                              .allTyping.last.textSpan.style.color);
                        }

                        focusNode.requestFocus();
                        karaokeCardDecorator.startTyping();
                      },
                      icon: Icon(Icons.font_download, size: iconButtonSize),
                    ),
                    // Text/Drawing Size slider
                    SizedBox(
                      width: 105,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbColor: Colors.blueGrey,
                          trackHeight: 20,
                          trackShape: TriangularSliderTrackShape(
                              Theme.of(context).primaryColor),
                        ),
                        child: Slider.adaptive(
                          value: karaokeCardDecorator.size,
                          min: 8,
                          max: 40,
                          divisions: 32,
                          label: karaokeCardDecorator.size.round().toString(),
                          onChanged: (double sliderVal) {
                            karaokeCardDecorator.setSize(sliderVal);
                          },
                        ),
                      ),
                    ),
                    // Undo button
                    IconButton(
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        focusNode.unfocus();
                        karaokeCardDecorator.undoLast();
                        if (karaokeCardDecorator.isTyping)
                          setState(() {
                            textController.clear();
                          });
                      },
                      icon: Icon(LineAwesomeIcons.undo, size: iconButtonSize),
                    ),
                  ],
                ),
                // Color Select
                Row(
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: RawMaterialButton(
                        fillColor: Colors.black,
                        shape: CircleBorder(),
                        onPressed: () {
                          karaokeCardDecorator.setColor(Colors.black);
                          updateTextColor(Colors.black);
                        },
                        child: karaokeCardDecorator.color == Colors.black
                            ? Icon(Icons.check, size: 20, color: Colors.white)
                            : Container(height: 20),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: RawMaterialButton(
                        fillColor: Colors.white,
                        shape: CircleBorder(),
                        onPressed: () {
                          karaokeCardDecorator.setColor(Colors.white);
                          updateTextColor(Colors.white);
                        },
                        child: karaokeCardDecorator.color == Colors.white
                            ? Icon(Icons.check, size: 20)
                            : Container(height: 20),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: RawMaterialButton(
                        fillColor: Colors.green,
                        shape: CircleBorder(),
                        onPressed: () {
                          karaokeCardDecorator.setColor(Colors.green);
                          updateTextColor(Colors.green);
                        },
                        child: karaokeCardDecorator.color == Colors.green
                            ? Icon(Icons.check, size: 20)
                            : Container(height: 20),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: RawMaterialButton(
                        fillColor: Colors.blue,
                        shape: CircleBorder(),
                        onPressed: () {
                          karaokeCardDecorator.setColor(Colors.blue);
                          updateTextColor(Colors.blue);
                        },
                        child: karaokeCardDecorator.color == Colors.blue
                            ? Icon(Icons.check, size: 20)
                            : Container(height: 20),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: RawMaterialButton(
                        fillColor: Colors.pink,
                        shape: CircleBorder(),
                        onPressed: () {
                          karaokeCardDecorator.setColor(Colors.pink);
                          updateTextColor(Colors.pink);
                        },
                        child: karaokeCardDecorator.color == Colors.pink
                            ? Icon(Icons.check, size: 20)
                            : Container(height: 20),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: RawMaterialButton(
                        fillColor: Colors.purple,
                        shape: CircleBorder(),
                        onPressed: () {
                          karaokeCardDecorator.setColor(Colors.purple);
                          updateTextColor(Colors.purple);
                        },
                        child: karaokeCardDecorator.color == Colors.purple
                            ? Icon(Icons.check, size: 20)
                            : Container(height: 20),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: RawMaterialButton(
                        fillColor: Colors.yellow,
                        shape: CircleBorder(),
                        onPressed: () {
                          karaokeCardDecorator.setColor(Colors.yellow);
                          updateTextColor(Colors.yellow);
                        },
                        child: karaokeCardDecorator.color == Colors.yellow
                            ? Icon(Icons.check, size: 20)
                            : Container(height: 20),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    RawMaterialButton(
                      onPressed: karaokeCardDecorator.reset,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Reset",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 2.0,
                      fillColor: karaokeCardDecorator.isEmpty()
                          ? Colors.grey
                          : Theme.of(context).errorColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 2),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 2),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
