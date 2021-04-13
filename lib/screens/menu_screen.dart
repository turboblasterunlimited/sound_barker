import 'package:K9_Karaoke/animations/waggle.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_card_decoration_controller.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/screens/about_screen.dart';
import 'package:K9_Karaoke/screens/info_screen.dart';
import 'package:K9_Karaoke/screens/account_screen.dart';
import 'package:K9_Karaoke/screens/my_cards.dart';
import 'package:K9_Karaoke/screens/photo_library_screen.dart';
import 'package:K9_Karaoke/widgets/custom_appbar.dart';
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
  KaraokeCardDecorationController cardDecorator;

  void handleCreateNewCard() {
    cards.newCurrent();
    cardDecorator.reset();
    currentActivity.setCardCreationStep(CardCreationSteps.snap);
    currentActivity.startCreateCard();
    Navigator.of(context).popAndPushNamed(PhotoLibraryScreen.routeName);
  }

  void handleMyCards() {
    Navigator.of(context).popAndPushNamed(MyCardsScreen.routeName);
  }

  Widget build(BuildContext context) {
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);
    cards = Provider.of<KaraokeCards>(context, listen: false);
    cardDecorator =
        Provider.of<KaraokeCardDecorationController>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(isMenu: true, isMainMenu: true),
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
                  child: Waggle(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "New Card",
                          style: TextStyle(
                              fontSize: 40,
                              color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: handleMyCards,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("My Cards",
                      style: TextStyle(
                          fontSize: 40, color: Theme.of(context).primaryColor)),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushNamed(AccountScreen.routeName),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Account",
                      style: TextStyle(
                          fontSize: 40, color: Theme.of(context).primaryColor)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(AboutScreen.routeName);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("About",
                      style: TextStyle(
                          fontSize: 40, color: Theme.of(context).primaryColor)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(InfoScreen.routeName);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("How To Use",
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
