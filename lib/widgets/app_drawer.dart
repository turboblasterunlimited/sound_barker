import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

import '../screens/main_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Drawer(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  AppBar(
                    iconTheme: IconThemeData(
                        color: Theme.of(context).accentColor, size: 30),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    actions: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: RawMaterialButton(
                          child: Icon(LineAwesomeIcons.bars),
                          elevation: 2.0,
                          // fillColor: Theme.of(context).accentColor,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                    leading: Icon(LineAwesomeIcons.paw),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.mic),
                    title: Text('Recording Booth'),
                    onTap: () {
                      Navigator.popUntil(
                        context,
                        ModalRoute.withName(MainScreen.routeName),
                      );
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.portrait),
                    title: Text('Account'),
                    onTap: () {
                      Navigator.popUntil(
                        context,
                        ModalRoute.withName(MainScreen.routeName),
                      );
                    },
                  ),
                  Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
