import 'package:K9_Karaoke/providers/sound_controller.dart';
import 'package:K9_Karaoke/services/gcloud.dart';
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/classes/card_decoration.dart';
import 'package:K9_Karaoke/providers/karaoke_card_decorator.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:uuid/uuid.dart';

class CardDecorator extends StatefulWidget {
  final cardAudioFilePath;
  final cardAudioId;
  final cardAmplitudes;
  final pictureId;
  CardDecorator(this.cardAudioFilePath, this.cardAudioId, this.cardAmplitudes, this.pictureId);

  @override
  _CardDecoratorState createState() => _CardDecoratorState();
}

class _CardDecoratorState extends State<CardDecorator> {
  SoundController soundController;
  KaraokeCardDecorator karaokeCardDecorator;
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
    stopPlayback();
    focusNode.dispose();
    super.dispose();
  }

  void stopPlayback() {
    if (_isPlaying) {
      print("called stop playback");
      imageController.stopAnimation();
      soundController.stopPlayer();
      setState(() => _isPlaying = false);
    }
  }

  void playCard() {
    print("Card audio filepath: ${widget.cardAudioFilePath}");
    soundController.startPlayer(widget.cardAudioFilePath, stopPlayback);
    imageController.mouthTrackSound(amplitudes: widget.cardAmplitudes);
    setState(() => _isPlaying = true);
  }

  void uploadAndShare() async {
    String decorationImageId = Uuid().v4();
    String decorationImageFilePath = await karaokeCardDecorator.cardPainter.capturePNG(decorationImageId);
    await Gcloud.uploadCardAssets(widget.cardAudioFilePath, decorationImageFilePath);
    await RestAPI.createCardOnServer(decorationImageId, widget.cardAudioId, widget.cardAmplitudes, widget.pictureId);
  }

  @override
  Widget build(BuildContext context) {
    soundController = Provider.of<SoundController>(context);
    imageController = Provider.of<ImageController>(context);
    karaokeCardDecorator = Provider.of<KaraokeCardDecorator>(context);

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
                // Draw, Type, or Erase.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    // Drawing button
                    RawMaterialButton(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      fillColor: karaokeCardDecorator.isDrawing
                          ? Colors.amber[900]
                          : Colors.amber[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      onPressed: () {
                        focusNode.unfocus();
                        karaokeCardDecorator.startDrawing();
                      },
                      child: Icon(Icons.edit),
                    ),
                    // Typing button
                    RawMaterialButton(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      fillColor: karaokeCardDecorator.isTyping
                          ? Colors.amber[900]
                          : Colors.amber[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
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
                        karaokeCardDecorator.undoLast();
                        if (karaokeCardDecorator.isTyping)
                          setState(() {
                            textController.clear();
                          });
                      },
                      child: Icon(LineAwesomeIcons.undo),
                    ),
                  ],
                ),
                // Playback and Share
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        child: _isPlaying
                            ? Icon(LineAwesomeIcons.stop)
                            : Icon(LineAwesomeIcons.play),
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
                        child: Icon(Icons.share),
                      ),
                    ],
                  ),
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
