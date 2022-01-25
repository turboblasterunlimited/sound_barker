
import 'package:flutter/material.dart';

class Waggle extends StatefulWidget {
  final Widget? child;

  Waggle({this.child});

  @override
  _WaggleState createState() => _WaggleState();
}

class _WaggleState extends State<Waggle> with SingleTickerProviderStateMixin {
  late Animation animation;
  late AnimationController animationController;

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    animationController.repeat(reverse: true);
    animation = CurveTween(curve: Curves.elasticIn).animate(animationController)
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget? child) {
          return Transform.rotate(
            angle: animation.value * 0.1,
            child: widget.child,
          );
        });
  }
}
