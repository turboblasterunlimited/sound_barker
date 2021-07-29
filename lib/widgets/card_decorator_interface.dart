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
  KaraokeCardDecorationController decorationController;
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
    cards.current.decoration.removeEmptyTypings();
    focusNode.dispose();
    super.dispose();
  }

  void stopPlayback() {
    imageController.stopAnimation();
    soundController.stopPlayer();
  }

  void _handleUndo() {
    focusNode.unfocus();
    decorationController.undoLast();
    if (decorationController.isTyping)
      setState(() {
        textController.clear();
      });
  }

  void _handleReset() {
    decorationController.reset();
    setState(() {
      textController.clear();
    });
  }

  List<Widget> _colorButtons() {
    return [
      Colors.black,
      Colors.white,
      Colors.blueGrey,
      Colors.brown,
      Colors.red[800],
      Colors.red,
      Colors.redAccent,
      Colors.deepOrange,
      Colors.deepOrangeAccent,
      Colors.orange,
      Colors.orangeAccent,
      Colors.amber,
      Colors.amberAccent,
      Colors.yellow,
      Colors.yellowAccent,
      Colors.lightGreenAccent,
      Colors.green,
      Colors.lightGreen,
      Colors.greenAccent,
      Colors.tealAccent,
      Colors.cyanAccent,
      Colors.cyan,
      Colors.blueAccent,
      Colors.indigoAccent,
      Colors.indigo,
      Colors.deepPurple,
      Colors.deepPurpleAccent,
      Colors.purpleAccent,
      Colors.pink,
      Colors.pinkAccent,
    ]
        .map(
          (color) => GestureDetector(
            onTap: () {
              decorationController.setColor(color);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Container(
                height: 30,
                width: 28,
                decoration: decorationController.color == color
                    ? BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        border: Border.all(
                          color: Colors.blue,
                          width: 3,
                        ),
                      )
                    : BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.all(Radius.circular(15))),
              ),
            ),
          ),
        )
        .toList();
  }

  double iconButtonSize = 30;

  void backCallback() {
    currentActivity.setPreviousSubStep();
  }

  void skipCallback() {
    print("next substep");
    currentActivity.setNextSubStep();
  }

  @override
  Widget build(BuildContext context) {
    soundController ??= Provider.of<SoundController>(context);
    imageController ??= Provider.of<ImageController>(context, listen: false);
    decorationController ??=
        Provider.of<KaraokeCardDecorationController>(context);
    canvasLength ??= MediaQuery.of(context).size.width;
    cards ??= Provider.of<KaraokeCards>(context);
    currentActivity ??= Provider.of<CurrentActivity>(context);
    decorationController.setDecoration(cards.current.decoration, canvasLength);
    decorationController.setTextController(textController, focusNode);

    return Container(
      height: 174,
      child: Stack(
        children: <Widget>[
          Visibility(
            visible: false,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            child: TextField(
              onTap: null,
              controller: textController,
              focusNode: focusNode,
              onChanged: (text) {
                print("Text: $text");
                decorationController.updateText(text);
              },
              onSubmitted: (_) {},
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: backCallback,
                    child: Row(children: <Widget>[
                      Icon(LineAwesomeIcons.angle_left,
                          color: Theme.of(context).primaryColor),
                      Text(
                        'Back',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ]),
                  ),
                  // Drawing button
                  Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: RawMaterialButton(
                      onPressed: () {
                        focusNode.unfocus();
                        decorationController.startDrawing();
                      },
                      // constraints:
                      //     BoxConstraints(minWidth: 52.0, minHeight: 30.0),
                      child: Text(
                        "Draw",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: decorationController.isDrawing
                                ? Colors.white
                                : Theme.of(context).primaryColor,
                            fontSize: 15),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0),
                        side: BorderSide(
                            color: Theme.of(context).primaryColor, width: 3),
                      ),
                      elevation: 2.0,
                      fillColor: decorationController.isDrawing
                          ? Theme.of(context).primaryColor
                          : null,
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 5,
                      ),
                    ),
                  ),
                  // Typing button

                  Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: RawMaterialButton(
                      onPressed: () {
                        focusNode.unfocus();
                        focusNode.requestFocus();
                        decorationController.startTyping();
                      },
                      // constraints:
                      //     BoxConstraints(minWidth: 52.0, minHeight: 30.0),
                      child: Text(
                        "Type",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: decorationController.isTyping
                                ? Colors.white
                                : Theme.of(context).primaryColor,
                            fontSize: 15),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0),
                        side: BorderSide(
                            color: Theme.of(context).primaryColor, width: 3),
                      ),
                      elevation: 2.0,
                      fillColor: decorationController.isTyping
                          ? Theme.of(context).primaryColor
                          : null,
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 5,
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: skipCallback,
                    child: Row(children: <Widget>[
                      Text(
                        'Skip',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      Icon(LineAwesomeIcons.angle_right,
                          color: Theme.of(context).primaryColor),
                    ]),
                  ),
                ],
              ),
              // Text/Drawing Size slider
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Size:",
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              thumbColor: Colors.blue[700],
                              trackHeight: 10,
                              trackShape: TriangularSliderTrackShape(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                            child: Slider(
                              value: decorationController.size,
                              min: 8,
                              max: 40,
                              divisions: 32,
                              label:
                                  decorationController.size.round().toString(),
                              onChanged: (double sliderVal) {
                                decorationController.setSize(sliderVal);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Undo button
                    GestureDetector(
                      onTap: _handleUndo,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Undo:",
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, bottom: 5.0),
                            child: Icon(CustomIcons.undo,
                                color: Theme.of(context).primaryColor,
                                size: iconButtonSize),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Color select
              Container(
                height: 30,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _colorButtons()),
                ),
              ),
              // Reset/Check buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MaterialButton(
                      height: 15,
                      minWidth: 50,
                      onPressed: _handleReset,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: FittedBox(
                          child: Text(
                            "Reset",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 2.0,
                      color: Theme.of(context).errorColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 2),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                    ),
                    MaterialButton(
                      height: 15,
                      minWidth: 50,
                      onPressed: () {
                        decorationController.startDrawing();
                        currentActivity.setNextSubStep();
                      },
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 27,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 2.0,
                      color: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
