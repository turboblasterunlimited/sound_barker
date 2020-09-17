import 'package:K9_Karaoke/providers/barks.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/pictures.dart';
import 'package:K9_Karaoke/providers/songs.dart';
import 'package:K9_Karaoke/providers/user.dart';
import 'package:K9_Karaoke/screens/authentication_screen.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  static const routeName = 'account-screen';

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<AccountScreen> {
  User user;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  KaraokeCards cards;
  Songs songs;
  Barks barks;
  Pictures pictures;

  void _showError(message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text("The following error occured: $message"),
      ),
    );
  }

  void _removeData() {
    cards.all = [];
    pictures.all = [];
    barks.all = [];
    songs.all = [];
  }

  void _deleteFiles() {
    cards.deleteAll();
    pictures.deleteAll();
    barks.deleteAll();
    songs.deleteAll();
  }

  void _handleLogout() async {
    var response = await user.logout();
    if (response["success"]) {
      _removeData();
      Navigator.of(context).popUntil(ModalRoute.withName("main-screen"));
      Navigator.of(context).popAndPushNamed(AuthenticationScreen.routeName);
    } else {
      _showError(response["error"]);
    }
  }

  void _handleDeleteAccount() async {
    var response = await user.delete();
    if (response["success"]) {
      _deleteFiles();
      _removeData();
      Navigator.of(context).popUntil(ModalRoute.withName("main-screen"));
      Navigator.of(context).popAndPushNamed(AuthenticationScreen.routeName);
    } else {
      _showError(response["error"]);
    }
  }

  Widget build(BuildContext context) {
    user = Provider.of<User>(context, listen: false);
    cards = Provider.of<KaraokeCards>(context, listen: false);
    songs = Provider.of<Songs>(context, listen: false);
    barks = Provider.of<Barks>(context, listen: false);
    pictures = Provider.of<Pictures>(context, listen: false);

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Don't show the leading button
        toolbarHeight: 80,

        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset("assets/logos/K9_logotype.png", width: 100),
          ],
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: RawMaterialButton(
              child: Icon(
                Icons.close,
                color: Colors.black,
                size: 30,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              onPressed: Navigator.of(context).pop,
            ),
          ),
        ],
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Subscription",
                    style: TextStyle(
                        fontSize: 40, color: Theme.of(context).primaryColor)),
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
