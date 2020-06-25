import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/screens/main_screen.dart';
import 'package:K9_Karaoke/screens/picture_menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatefulWidget {
  static const routeName = 'menu-screen';

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<MenuScreen> {
  CurrentActivity currentActivity;
  Widget build(BuildContext context) {
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      resizeToAvoidBottomPadding: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).primaryColor, size: 30),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: Icon(LineAwesomeIcons.paw),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: RawMaterialButton(
                child: Icon(
                  Icons.menu,
                  color: Colors.black,
                  size: 30,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                // fillColor: Theme.of(context).accentColor,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                currentActivity.startCreateCard();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    PictureMenuScreen.routeName,
                    (route) => route.settings.name == MainScreen.routeName);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Create New Card",
                    style: TextStyle(
                        fontSize: 40, color: Theme.of(context).primaryColor)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("View Cards",
                  style: TextStyle(
                      fontSize: 40, color: Theme.of(context).primaryColor)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Photo Library",
                  style: TextStyle(
                      fontSize: 40, color: Theme.of(context).primaryColor)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Song Library",
                  style: TextStyle(
                      fontSize: 40, color: Theme.of(context).primaryColor)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Bark Library",
                  style: TextStyle(
                      fontSize: 40, color: Theme.of(context).primaryColor)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Account",
                  style: TextStyle(
                      fontSize: 40, color: Theme.of(context).primaryColor)),
            ),
            Container(
              width: 120,
              child: Divider(
                color: Theme.of(context).primaryColor,
                height: 10,
                thickness: 3,
                indent: 20,
                endIndent: 20,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                      icon: Icon(LineAwesomeIcons.facebook,
                          size: 40, color: Theme.of(context).primaryColor),
                      onPressed: null),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                      icon: Icon(LineAwesomeIcons.instagram,
                          size: 40, color: Theme.of(context).primaryColor),
                      onPressed: null),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                      icon: Icon(LineAwesomeIcons.twitter,
                          size: 40, color: Theme.of(context).primaryColor),
                      onPressed: null),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
