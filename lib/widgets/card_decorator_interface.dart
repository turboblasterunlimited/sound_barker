import 'package:K9_Karaoke/components/triangular_slider_track_shape.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/sound_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/providers/karaoke_card_decoration_controller.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import '../icons/custom_icons.dart';

class CardDecoratorInterface extends StatefulWidget {
  @override
  _CardDecoratorInterfaceState createState() => _CardDecoratorInterfaceState();
}

class _CardDecoratorInterfaceState extends State<CardDecoratorInterface> {
  SoundController soundController;
  KaraokeCardDecorationController karaokeCardDecorator;
  ImageController imageController;
  CurrentActivity currentActivity;
  KaraokeCards cards;
  FocusNode focusNode;
  double canvasLength;
  final textController = TextEditingController();

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
    imageController.stopAnimation();
    soundController.stopPlayer();
  }

  void _handleUndo() {
    focusNode.unfocus();
    karaokeCardDecorator.undoLast();
    if (karaokeCardDecorator.isTyping)
      setState(() {
        textController.clear();
      });
  }

  void _handleReset() {
    karaokeCardDecorator.reset();
    setState(() {
      textController.clear();
    });
  }

  double iconButtonSize = 35;

  @override
  Widget build(BuildContext context) {
    soundController ??= Provider.of<SoundController>(context);
    imageController ??= Provider.of<ImageController>(context, listen: false);
    karaokeCardDecorator ??=
        Provider.of<KaraokeCardDecorationController>(context);
    canvasLength ??= MediaQuery.of(context).size.width;
    cards ??= Provider.of<KaraokeCards>(context);
    currentActivity ??= Provider.of<CurrentActivity>(context);
    karaokeCardDecorator.setDecoration(cards.current.decoration, canvasLength);


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
                karaokeCardDecorator.updateText(text);
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
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: IconButton(
                        color: karaokeCardDecorator.isDrawing
                            ? Colors.blue
                            : Theme.of(context).primaryColor,
                        onPressed: () {
                          focusNode.unfocus();
                          karaokeCardDecorator.startDrawing();
                        },
                        icon: Icon(CustomIcons.draw, size: iconButtonSize + 10),
                      ),
                    ),
                    // Typing button
                    IconButton(
                      color: karaokeCardDecorator.isTyping
                          ? Colors.blue
                          : Theme.of(context).primaryColor,
                      onPressed: () {
                        focusNode.unfocus();
                        focusNode.requestFocus();
                        karaokeCardDecorator.startTyping();
                      },
                      icon: Icon(CustomIcons.aa, size: iconButtonSize + 10),
                    ),
                    // Text/Drawing Size slider
                    SizedBox(
                      width: 105,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbColor: Colors.blue[700],
                          trackHeight: 20,
                          trackShape: TriangularSliderTrackShape(
                              Theme.of(context).primaryColor),
                        ),
                        child: Slider(
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
                      onPressed: _handleUndo,
                      icon: Icon(CustomIcons.undo, size: iconButtonSize),
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
                        },
                        child: karaokeCardDecorator.color == Colors.yellow
                            ? Icon(Icons.check, size: 20)
                            : Container(height: 20),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    RawMaterialButton(
                      onPressed: _handleReset,
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
                      fillColor: karaokeCardDecorator.decoration.isEmpty
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
