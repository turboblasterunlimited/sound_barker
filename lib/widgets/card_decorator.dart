import 'package:K9_Karaoke/providers/sound_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/classes/drawing_typing.dart';
import 'package:K9_Karaoke/providers/card_decorator_provider.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

class CardDecorator extends StatefulWidget {
  final cardAudioFilePath;
  final cardAmplitudes;
  CardDecorator(this.cardAudioFilePath, this.cardAmplitudes);

  @override
  _CardDecoratorState createState() => _CardDecoratorState();
}

class _CardDecoratorState extends State<CardDecorator> {
  SoundController soundController;
  CardDecoratorProvider decoratorProvider;
  ImageController imageController;
  FocusNode focusNode;
  double canvasLength;
  final textController = TextEditingController();
  bool _isPlaying = false;

  @override
  void didChangeDependencies() {
    canvasLength ??= MediaQuery.of(context).size.width;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void stopPlayback() {
    imageController.stopAnimation();
    soundController.stopPlayer();
    if (mounted) setState(() => _isPlaying = false);
  }

  void playCard() {
    soundController.startPlayer(widget.cardAudioFilePath, stopPlayback);
    imageController.mouthTrackSound(amplitudes: widget.cardAmplitudes);
    if (mounted) setState(() => _isPlaying = true);
  }

  void uploadAndShare() {}

  @override
  Widget build(BuildContext context) {
    soundController = Provider.of<SoundController>(context);
    imageController = Provider.of<ImageController>(context);
    decoratorProvider = Provider.of<CardDecoratorProvider>(context);

    void updateTextColor(color) {
      if (decoratorProvider.isDrawing) return;
      var newTextSpan = TextSpan(
        text: decoratorProvider.allTyping.last.textSpan.text,
        style: TextStyle(color: color),
      );
      decoratorProvider.updateLastTextSpan(newTextSpan);
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
                  style: TextStyle(color: decoratorProvider.color),
                );
                decoratorProvider.updateLastTextSpan(newTextSpan);
              },
              onSubmitted: (text) {},
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // Color Select
                Row(
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: RawMaterialButton(
                        fillColor: Colors.black,
                        shape: CircleBorder(),
                        onPressed: () {
                          decoratorProvider.setColor(Colors.black);
                          updateTextColor(Colors.black);
                        },
                        child: decoratorProvider.color == Colors.black
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
                          decoratorProvider.setColor(Colors.white);
                          updateTextColor(Colors.white);
                        },
                        child: decoratorProvider.color == Colors.white
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
                          decoratorProvider.setColor(Colors.green);
                          updateTextColor(Colors.green);
                        },
                        child: decoratorProvider.color == Colors.green
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
                          decoratorProvider.setColor(Colors.blue);
                          updateTextColor(Colors.blue);
                        },
                        child: decoratorProvider.color == Colors.blue
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
                          decoratorProvider.setColor(Colors.pink);
                          updateTextColor(Colors.pink);
                        },
                        child: decoratorProvider.color == Colors.pink
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
                          decoratorProvider.setColor(Colors.purple);
                          updateTextColor(Colors.purple);
                        },
                        child: decoratorProvider.color == Colors.purple
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
                          decoratorProvider.setColor(Colors.yellow);
                          updateTextColor(Colors.yellow);
                        },
                        child: decoratorProvider.color == Colors.yellow
                            ? Icon(Icons.check, size: 20)
                            : Container(height: 20),
                      ),
                    ),
                  ],
                ),
                // Draw, Type, or Erase.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    // Drawing button
                    RawMaterialButton(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      fillColor: decoratorProvider.isDrawing
                          ? Colors.amber[900]
                          : Colors.amber[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      onPressed: () {
                        focusNode.unfocus();
                        decoratorProvider.startDrawing();
                      },
                      child: Icon(Icons.edit),
                    ),
                    // Typing button
                    RawMaterialButton(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      fillColor: decoratorProvider.isTyping
                          ? Colors.amber[900]
                          : Colors.amber[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      onPressed: () {
                        focusNode.unfocus();
                        if (decoratorProvider.allTyping.isEmpty) {
                          decoratorProvider.allTyping.add(
                            Typing(
                              TextSpan(
                                text: "",
                                style: TextStyle(
                                    color: decoratorProvider.color,
                                    fontSize: 40),
                              ),
                              Offset(canvasLength / 2, canvasLength - 50),
                            ),
                          );
                          // set color to textSpan that is being edited
                        } else if (decoratorProvider.color !=
                            decoratorProvider
                                .allTyping.last.textSpan.style.color) {
                          decoratorProvider.setColor(decoratorProvider
                              .allTyping.last.textSpan.style.color);
                        }

                        focusNode.requestFocus();
                        decoratorProvider.startTyping();
                      },
                      child: Icon(Icons.font_download),
                    ),
                    // Undo button
                    RawMaterialButton(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      fillColor: Colors.amber[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      onPressed: () {
                        focusNode.unfocus();
                        decoratorProvider.undoLast();
                        if (decoratorProvider.isTyping)
                          setState(() {
                            textController.clear();
                          });
                      },
                      child: Icon(LineAwesomeIcons.undo),
                    ),
                  ],
                ),
                // Playback and Share
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RawMaterialButton(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      fillColor: Colors.amber[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      onPressed: () {
                        _isPlaying ? stopPlayback() : playCard();
                      },
                      child: _isPlaying ? Icon(LineAwesomeIcons.stop) : Icon(LineAwesomeIcons.play),
                    ),
                    RawMaterialButton(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      fillColor: Colors.amber[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      onPressed: () {
                        uploadAndShare();
                      },
                      child: Icon(LineAwesomeIcons.share),
                    ),
                  ],
                ),

                // Choose Border Decorations
                Visibility(
                  visible: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RawMaterialButton(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        fillColor: Colors.amber[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        onPressed: () {
                          imageController.webViewController
                              .evaluateJavascript("test_render()");
                        },
                        child: Icon(LineAwesomeIcons.gift),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
