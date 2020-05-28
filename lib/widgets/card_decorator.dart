import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_barker/providers/decorator.dart';

class CardDecorator extends StatefulWidget {
  CardDecorator();

  @override
  _CardDecoratorState createState() => _CardDecoratorState();
}

class _CardDecoratorState extends State<CardDecorator> {
  Decorator decoratorProvider;
  @override
  Widget build(BuildContext context) {
    decoratorProvider = Provider.of<Decorator>(context);
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
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
            children: <Widget>[],
          ),
        ],
      ),
    );
  }
}
