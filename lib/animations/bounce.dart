import 'package:flutter/material.dart';

class Bounce extends StatefulWidget {
  Icon icon;
  double begin;
  double end;

  Bounce({this.icon, this.begin, this.end});

  @override
  _BounceState createState() => _BounceState();
}

class _BounceState extends State<Bounce>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  var tween;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);
    tween = Tween(begin: widget.begin, end: widget.end).animate(animationController);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget child) {
          return Positioned(
            bottom: tween.value,
            left: 0,
            right: 0,
            child: widget.icon,
          );
        });
  }
}
