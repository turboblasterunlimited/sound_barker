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
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false, // Don't show the leading button
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset("assets/images/K9_logotype.png", width: 100),
              // Your widgets here
            ],
          ),
          // Can only close if activity already selected
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: RawMaterialButton(
                child: Visibility(
                  visible: currentActivity.activitySelected(),
                  child: Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                // fillColor: Theme.of(context).accentColor,
                onPressed: currentActivity.activitySelected()
                    ? () => Navigator.of(context).pop()
                    : null,
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
                Navigator.of(context).pushNamed(PictureMenuScreen.routeName);
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
