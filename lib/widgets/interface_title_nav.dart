import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ignore: must_be_immutable
class InterfaceTitleNav extends StatefulWidget {
  String? title;
  Widget? titleWidget;
  VoidCallback? backCallback;
  Function? skipCallback;
  double? titleSize;

  InterfaceTitleNav(
      {this.title,
      this.titleWidget,
      this.backCallback,
      this.skipCallback,
      this.titleSize});

  @override
  _InterfaceTitleNavState createState() => _InterfaceTitleNavState();
}

class _InterfaceTitleNavState extends State<InterfaceTitleNav> {
  @override
  Widget build(BuildContext context) {
    double screenSize = MediaQuery.of(context).size.width;
    /**
     * JMF: Removing condition screenSize > 400, makes assumption
     * about title lengths.
     */
    //widget.titleSize = screenSize > 400 ? 25 : widget.titleSize;

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
                  Icon(FontAwesomeIcons.angleLeft,
                      color: Theme.of(context).primaryColor),
                  Text('Back',
                      style: TextStyle(color: Theme.of(context).primaryColor)),
                ],
              ),
            ),
          ),
        Align(
          alignment: Alignment.topCenter,
          child: widget.titleWidget != null
              ? widget.titleWidget
              : Text(
                  widget.title!,
                  style: TextStyle(
                      fontSize: widget.titleSize ?? 18,
                      color: Theme.of(context).primaryColor),
                ),
        ),
        if (widget.skipCallback != null)
          Positioned(
            right: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                await widget.skipCallback!();
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Row(
                  children: <Widget>[
                    Text('Skip',
                        style:
                            TextStyle(color: Theme.of(context).primaryColor)),
                    Icon(FontAwesomeIcons.angleRight,
                        color: Theme.of(context).primaryColor),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
