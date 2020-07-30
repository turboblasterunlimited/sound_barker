import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/screens/account_screen.dart';
import 'package:K9_Karaoke/screens/photo_library_screen.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatefulWidget {
  static const routeName = 'menu-screen';

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<MenuScreen> {
  KaraokeCards cards;
  CurrentActivity currentActivity;

  void handleCreateNewCard() {
    if (currentActivity.cardCreation) {
      Navigator.of(context).popAndPushNamed(PhotoLibraryScreen.routeName);
    } else {
      currentActivity.startCreateCard(cards.newCurrent);
      Navigator.popAndPushNamed(
        context,
        PhotoLibraryScreen.routeName,
      );
    }
  }

  Widget build(BuildContext context) {
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);
    cards = Provider.of<KaraokeCards>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      extendBodyBehindAppBar: true,
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
              Image.asset("assets/logos/K9_logotype.png", width: 100),
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
      body: Container(
        padding: EdgeInsets.only(top: 60),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/menu_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: handleCreateNewCard,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Create New Card",
                      style: TextStyle(
                          fontSize: 40, color: Theme.of(context).primaryColor)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("My Cards",
                    style: TextStyle(
                        fontSize: 40, color: Theme.of(context).primaryColor)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("My Photos",
                    style: TextStyle(
                        fontSize: 40, color: Theme.of(context).primaryColor)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("My Songs",
                    style: TextStyle(
                        fontSize: 40, color: Theme.of(context).primaryColor)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("My Barks",
                    style: TextStyle(
                        fontSize: 40, color: Theme.of(context).primaryColor)),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(AccountScreen.routeName),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Account",
                      style: TextStyle(
                          fontSize: 40, color: Theme.of(context).primaryColor)),
                ),
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
      ),
    );
  }
}
