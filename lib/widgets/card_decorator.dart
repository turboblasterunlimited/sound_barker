import 'package:flutter/material.dart';

class CardDecorator extends StatefulWidget {
  CardDecorator();

  @override
  _CardDecoratorState createState() => _CardDecoratorState();
}

class _CardDecoratorState extends State<CardDecorator> {
  bool _isDrawing = false;
  bool _isTyping = false;
  @override
  Widget build(BuildContext context) {
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
                fillColor: _isTyping ? Colors.amber[900] : Colors.amber[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                ),
                onPressed: () {
                  setState(() {
                    _isTyping = true;
                    _isDrawing = false;
                  });
                },
                child: Icon(Icons.font_download),
              ),
              RawMaterialButton(
                padding: EdgeInsets.symmetric(vertical: 20),
                fillColor: _isDrawing ? Colors.amber[900] : Colors.amber[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                ),
                onPressed: () {
                  setState(() {
                    _isTyping = false;
                    _isDrawing = true;
                  });
                },
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
