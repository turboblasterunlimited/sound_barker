import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_barker/providers/decorator.dart';
import 'package:song_barker/providers/image_controller.dart';

class CardDecorator extends StatefulWidget {
  CardDecorator();

  @override
  _CardDecoratorState createState() => _CardDecoratorState();
}

class _CardDecoratorState extends State<CardDecorator> {
  Decorator decoratorProvider;
  ImageController imageController;

  @override
  Widget build(BuildContext context) {
    imageController = Provider.of<ImageController>(context);
    decoratorProvider = Provider.of<Decorator>(context);
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          // Color Select
          Row(
            // mainAxisAlignment: MainAxisAlignment.center,
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
            ],
          ),
          // Draw or Type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
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
                fillColor: decoratorProvider.isDrawing
                    ? Colors.amber[900]
                    : Colors.amber[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                ),
                onPressed: decoratorProvider.startDrawing,
                child: Icon(Icons.edit),
              ),
            ],
          ),
          // Choose Border Decorations
          Row(
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
                child: Icon(Icons.file_download),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
