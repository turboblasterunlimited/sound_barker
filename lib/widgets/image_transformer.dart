import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../widgets/main_barks_list.dart';

class ImageTransform extends StatefulWidget {
  ImageTransform();

  @override
  _ImageTransformState createState() => _ImageTransformState();
}

class _ImageTransformState extends State<ImageTransform>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 7),
    );

    animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      alignment: Alignment.center,
      color: Colors.white,
      child: new AnimatedBuilder(
        animation: animationController,
        child: new Container(
          height: 150.0,
          width: 150.0,
          child: new Image.asset('assets/images/jackie.jpeg'),
        ),
        builder: (BuildContext context, Widget _widget) { 
          return MainBarksList();
          // return Transform.scale();
        },
      ),
    );
  }
}