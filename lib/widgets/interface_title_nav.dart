import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';



Widget interfaceTitleNav(BuildContext context, String title,
    {Function backCallback, Function skipCallback}) {
  return Stack(
    children: <Widget>[
      if (backCallback != null)
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: backCallback,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Icon(LineAwesomeIcons.angle_left),
                Text('Back'),
              ],
            ),
          ),
        ),
      Positioned.fill(
        child: Align(
          alignment: Alignment.center,
          child: Text(
            title,
            style:
                TextStyle(fontSize: 18, color: Theme.of(context).primaryColor),
          ),
        ),
      ),
      if (skipCallback != null)
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: backCallback,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Icon(LineAwesomeIcons.angle_left),
                Text('Skip'),
              ],
            ),
          ),
        ),
    ],
  );
}
