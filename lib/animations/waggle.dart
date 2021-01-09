import 'package:flutter/material.dart';

class Waggle extends StatefulWidget {
  Widget child;

  Waggle({this.child});

  @override
  _WaggleState createState() => _WaggleState();
}

class _WaggleState extends State<Waggle> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  var tween;

  Animation _animation;
  AnimationController _animationController;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    _animation =
        CurveTween(curve: Curves.elasticIn).animate(_animationController)
          ..addListener(() {
            setState(() {});
          });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget child) {
          return Transform.rotate(
            angle: _animation.value * 0.1,
            child: widget.child,
          );
        });
  }
}
