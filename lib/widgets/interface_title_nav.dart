import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

class InterfaceTitleNav extends StatefulWidget {
  String title;
  Function backCallback;
  Function skipCallback;
  double titleSize;

  InterfaceTitleNav(this.title,
      {this.backCallback, this.skipCallback, this.titleSize});

  @override
  _InterfaceTitleNavState createState() => _InterfaceTitleNavState();
}

class _InterfaceTitleNavState extends State<InterfaceTitleNav> {
  @override
  Widget build(BuildContext context) {
    double screenSize = MediaQuery.of(context).size.width;
    widget.titleSize = screenSize > 400 ? 25 : widget.titleSize;
    
    return Stack(
      children: <Widget>[
        if (widget.backCallback != null)
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.backCallback,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
              widget.title,
              style: TextStyle(
                  fontSize: widget.titleSize ?? 18,
                  color: Theme.of(context).primaryColor),
            ),
          ),
        ),
        if (widget.skipCallback != null)
          Positioned(
            right: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                await widget.skipCallback();
              },
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
}
