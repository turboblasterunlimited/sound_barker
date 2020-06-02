import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_barker/providers/card_decorator_provider.dart';
import 'package:song_barker/providers/image_controller.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';


class CardDecorator extends StatefulWidget {
  CardDecorator();

  @override
  _CardDecoratorState createState() => _CardDecoratorState();
}

class _CardDecoratorState extends State<CardDecorator> {
  CardDecoratorProvider decoratorProvider;
  ImageController imageController;

  @override
  Widget build(BuildContext context) {
    imageController = Provider.of<ImageController>(context);
    decoratorProvider = Provider.of<CardDecoratorProvider>(context);
    return Expanded(
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
                  onPressed: () => decoratorProvider.setColor(Colors.black),
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
                  onPressed: () => decoratorProvider.setColor(Colors.white),
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
                  onPressed: () => decoratorProvider.setColor(Colors.green),
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
                  onPressed: () => decoratorProvider.setColor(Colors.blue),
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
                  onPressed: () => decoratorProvider.setColor(Colors.pink),
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
                  onPressed: () => decoratorProvider.setColor(Colors.purple),
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
                  onPressed: () => decoratorProvider.setColor(Colors.yellow),
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
              RawMaterialButton(
                padding: EdgeInsets.symmetric(vertical: 20),
                fillColor: decoratorProvider.isDrawing
                    ? Colors.amber[900]
                    : Colors.amber[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                ),
                onPressed: decoratorProvider.startDrawing,
                child: Icon(Icons.edit),
              ),
              RawMaterialButton(
                padding: EdgeInsets.symmetric(vertical: 20),
                fillColor: decoratorProvider.isTyping
                    ? Colors.amber[900]
                    : Colors.amber[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                ),
                onPressed: decoratorProvider.startTyping,
                child: Icon(Icons.font_download),
              ),
              RawMaterialButton(
                padding: EdgeInsets.symmetric(vertical: 20),
                fillColor: Colors.amber[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                ),
                onPressed: decoratorProvider.undoLast,
                child: Icon(LineAwesomeIcons.undo),
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
    );
  }
}
