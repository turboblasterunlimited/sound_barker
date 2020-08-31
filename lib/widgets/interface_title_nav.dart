import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

Widget interfaceTitleNav(BuildContext context, String title,
    {Function backCallback, Function skipCallback, double titleSize}) {
  return Stack(
    children: <Widget>[
      if (backCallback != null)
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: backCallback,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
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
          alignment: Alignment.topCenter,
          child: Text(
            title,
            style: TextStyle(
                fontSize: titleSize ?? 18,
                color: Theme.of(context).primaryColor),
          ),
        ),
      ),
      if (skipCallback != null)
        Positioned(
          right: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: skipCallback,
            child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Row(
                children: <Widget>[
                  Text('Skip'),
                  Icon(LineAwesomeIcons.angle_right),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}
