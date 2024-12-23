import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/barks.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/pictures.dart';
import 'package:K9_Karaoke/providers/songs.dart';
import 'package:K9_Karaoke/providers/the_user.dart';
import 'package:K9_Karaoke/screens/authentication_screen.dart';
import 'package:K9_Karaoke/screens/main_screen.dart';
import 'package:K9_Karaoke/screens/subscription_screen.dart';
import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:K9_Karaoke/widgets/custom_dialog.dart';
import 'package:K9_Karaoke/widgets/error_dialog.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:K9_Karaoke/widgets/social_links_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/info_popup.dart';
import 'change_password_screen.dart';
import 'menu_screen.dart';

class AccountScreen extends StatefulWidget {
  static const routeName = 'account-screen';

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<AccountScreen> {
  TheUser? user;
//  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  KaraokeCards? cards;
  Songs? songs;
  Barks? barks;
  Pictures? pictures;

  final fontSize = 32.0;

  void _removeData() {
    cards!.removeAll();
    pictures!.removeAll();
    barks!.removeAll();
    songs!.removeAll();
  }

  void _deleteFiles() {
    cards!.deleteAll();
    pictures!.deleteAll();
    barks!.deleteAll();
    songs!.deleteAll();
  }

  void _showErrorDialog(BuildContext context, String message, [String title = "Change password not available for this account"]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Expanded(
              child:Text(message)
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
              var response = await user!.delete();
              if (response["success"]) {
                _deleteFiles();
                removeDataAndNavToAuth(modalContext);
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

  void removeDataAndNavToAuth(modalContext) {
    _removeData();
    Navigator.of(modalContext)
        .popUntil(ModalRoute.withName(MainScreen.routeName));
    Navigator.of(modalContext).popAndPushNamed(AuthenticationScreen.routeName);
  }

  void _handleLogout() async {
    return showDialog(
        context: context,
        builder: (BuildContext ctx) {
          var _email = user!.account_type == "Apple"
                    ? user!.apple_proxy_email
                    : user!.email;
          if(_email == InfoPopup.guest) {
            _email = InfoPopup.guest_label;
          }
          return CustomDialog(
            header: "Logout from ${_email}?",
            bodyText:
                "If you logout, you will have to login again to use K-9 Karaoke.",
            primaryFunction: (BuildContext modalContext) async {
              var response = await user!.logout();
              if (response["success"]) {
                removeDataAndNavToAuth(modalContext);
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

  bool _isPreview(TheUser? user) {
    return user!.email == InfoPopup.guest;
  }

  Widget build(BuildContext context) {
    user ??= Provider.of<TheUser>(context, listen: false);
    cards ??= Provider.of<KaraokeCards>(context, listen: false);
    songs ??= Provider.of<Songs>(context, listen: false);
    barks ??= Provider.of<Barks>(context, listen: false);
    pictures ??= Provider.of<Pictures>(context, listen: false);

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(isMenu: true, noName: true),
      body: Container(
        padding: EdgeInsets.only(top: 0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/menu_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 130, bottom: 10),
                child: InterfaceTitleNav(
                  title: "ACCOUNT",
                  titleSize: 22,
                  backCallback: () => Navigator.of(context)
                      .popAndPushNamed(MenuScreen.routeName),
                ),
              ),
              GestureDetector(
                onTap: () => _handleLogout(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Logout",
                      style: TextStyle(
                          fontSize: fontSize,
                          color: Theme.of(context).primaryColor)),
                ),
              ),
              GestureDetector(
                onTap: () => _isPreview(user)
                    ? InfoPopup.displayInfo(context, "Subscriptions aren't available to Guests..",
                                      InfoPopup.signup)
                    : Navigator.of(context).pushNamed(SubscriptionScreen.routeName),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Subscription",
                    style: TextStyle(
                        fontSize: fontSize,
                        color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_isPreview(user)) {
                    InfoPopup.displayInfo(context, "Guests have no password to change.",
                        InfoPopup.signup);
                  }
                  else if(user!.account_type == "email") {
                    Navigator.of(context)
                        .pushNamed(ChangePasswordScreen.routeName);
                  }
                  else {
                    var create = user!.account_type;
                    var message = "Change password is only available if account was created via email.";
                    message += "Your account was created via " + create! + " sign-in.";
                    InfoPopup.displayInfo(context, "Can't change password", message);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Change Password",
                    style: TextStyle(
                        fontSize: fontSize,
                        color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _isPreview(user)
                    ? InfoPopup.displayInfo(context, "Guests can't delete an account.",
                    InfoPopup.signup)
                    : _handleDeleteAccount(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Delete Account",
                    style: TextStyle(
                        fontSize: fontSize,
                        color: Theme.of(context).primaryColor),
                  ),
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
              socialLinksBar(context),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: <Widget>[
              //     Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: IconButton(
              //           icon: Icon(LineAwesomeIcons.facebook,
              //               size: 40, color: Theme.of(context).primaryColor),
              //           onPressed: null),
              //     ),
              //     Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: IconButton(
              //           icon: Icon(LineAwesomeIcons.instagram,
              //               size: 40, color: Theme.of(context).primaryColor),
              //           onPressed: null),
              //     ),
              //     Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: IconButton(
              //           icon: Icon(LineAwesomeIcons.twitter,
              //               size: 40, color: Theme.of(context).primaryColor),
              //           onPressed: null),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
