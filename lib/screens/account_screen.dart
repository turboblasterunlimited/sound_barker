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

  void _showError(message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text("The following error occured: $message"),
      ),
    );
  }

  void _handleLogout(c) async {
    var response = await user.logout();
    if (response == true) {
      Navigator.of(context).popUntil(ModalRoute.withName("main-screen"));
      Navigator.of(context).popAndPushNamed(AuthenticationScreen.routeName);
    } else {
      _showError(response);
    }
  }

  Widget build(BuildContext context) {
    user = Provider.of<User>(context, listen: false);

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
                onTap: () => _handleLogout(context),
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
