import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/barks.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/pictures.dart';
import 'package:K9_Karaoke/providers/songs.dart';
import 'package:K9_Karaoke/providers/the_user.dart';
import 'package:K9_Karaoke/screens/authentication_screen.dart';
import 'package:K9_Karaoke/screens/subscription_screen.dart';
import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:K9_Karaoke/widgets/custom_dialog.dart';
import 'package:K9_Karaoke/widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  static const routeName = 'account-screen';

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<AccountScreen> {
  TheUser user;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  KaraokeCards cards;
  Songs songs;
  Barks barks;
  Pictures pictures;

  void _removeData() {
    cards.removeAll();
    pictures.removeAll();
    barks.removeAll();
    songs.removeAll();
  }

  void _deleteFiles() {
    cards.deleteAll();
    pictures.deleteAll();
    barks.deleteAll();
    songs.deleteAll();
  }

  void _handleDeleteAccount() async {
    return showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CustomDialog(
            header: "Delete account?",
            bodyText:
                "All of your barks, songs, photos, and cards will be gone forever.\n\nThis cannot be undone.",
            primaryFunction: (BuildContext modalContext) {
              Navigator.of(modalContext).pop();
            },
            secondaryFunction: (BuildContext modalContext) async {
              var response = await user.delete();
              if (response["success"]) {
                _deleteFiles();
                _removeData();
                Navigator.of(modalContext)
                    .popUntil(ModalRoute.withName("main-screen"));
                Navigator.of(modalContext)
                    .popAndPushNamed(AuthenticationScreen.routeName);
              } else {
                showError(modalContext, response["error"]);
              }
            },
            iconPrimary: Icon(
              CustomIcons.modal_trashcan,
              size: 42,
              color: Colors.grey[300],
            ),
            iconSecondary: Icon(
              CustomIcons.modal_paws_topleft,
              size: 42,
              color: Colors.grey[300],
            ),
            isYesNo: true,
            primaryButtonText: "Go back",
            secondaryButtonText: "Delete",
          );
        });
  }

  void _handleLogout() async {
    return showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CustomDialog(
            header: "Logout from ${user.email}?",
            bodyText:
                "You don't have to logout to exit the app.\n\nYou will have to login again to use K-9 Karaoke.",
            primaryFunction: (BuildContext modalContext) async {
              var response = await user.logout();
              if (response["success"]) {
                _removeData();
                Navigator.of(modalContext)
                    .popUntil(ModalRoute.withName("main-screen"));
                Navigator.of(modalContext)
                    .popAndPushNamed(AuthenticationScreen.routeName);
              } else {
                showError(modalContext, response["error"]);
              }
            },
            iconPrimary: Icon(
              CustomIcons.modal_logout,
              size: 42,
              color: Colors.grey[300],
            ),
            iconSecondary: Icon(
              CustomIcons.modal_paws_topleft,
              size: 42,
              color: Colors.grey[300],
            ),
            isYesNo: true,
          );
        });
  }

  Widget build(BuildContext context) {
    user = Provider.of<TheUser>(context, listen: false);
    cards = Provider.of<KaraokeCards>(context, listen: false);
    songs = Provider.of<Songs>(context, listen: false);
    barks = Provider.of<Barks>(context, listen: false);
    pictures = Provider.of<Pictures>(context, listen: false);

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      extendBodyBehindAppBar: true,
      appBar: customAppBar(context, isMenu: true, pageTitle: "Account"),
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
                onTap: () => _handleLogout(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Logout",
                      style: TextStyle(
                          fontSize: 40, color: Theme.of(context).primaryColor)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Purchases",
                    style: TextStyle(
                        fontSize: 40, color: Theme.of(context).primaryColor)),
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushNamed(SubscriptionScreen.routeName),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Subscription",
                      style: TextStyle(
                          fontSize: 40, color: Theme.of(context).primaryColor)),
                ),
              ),
              GestureDetector(
                onTap: () => _handleDeleteAccount(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Delete Account",
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
