import 'package:K9_Karaoke/providers/the_user.dart';
import 'package:K9_Karaoke/screens/authentication_screen.dart';
import 'package:K9_Karaoke/screens/retrieve_data_screen.dart';

import 'package:K9_Karaoke/widgets/error_dialog.dart';
import 'package:K9_Karaoke/widgets/spinner_widget.dart';
import 'package:flutter/material.dart';

import 'package:K9_Karaoke/services/http_controller.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/globals.dart';

class CheckAuthenticationScreen extends StatefulWidget {
  static const routeName = '/';

  @override
  _CheckAuthenticationScreenState createState() =>
      _CheckAuthenticationScreenState();
}

class _CheckAuthenticationScreenState extends State<CheckAuthenticationScreen> {
  bool firstBuild = true;
  TheUser user;

  Future<Map> checkIfSignedIn() async {
    try {
      return (await HttpController.dio.get('https://$serverURL/is-logged-in'))
          ?.data;
    } catch (e) {
      showError(
        context,
      );
      return {};
    }
  }

  void _handleSignedIn(email) async {
    user.signIn(email);
    Navigator.of(context).popAndPushNamed(RetrieveDataScreen.routeName);
  }

  void _handleNotSignedIn() {
    Navigator.of(context).popAndPushNamed(AuthenticationScreen.routeName);
  }

  void signedInOrGotoAuthScreen() async {
    var response = await checkIfSignedIn();
    if (response["logged_in"] != null && response["logged_in"]) {
      _handleSignedIn(response["user_id"]);
    } else {
      _handleNotSignedIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<TheUser>(context, listen: false);

    if (firstBuild) {
      setState(() => firstBuild = false);
      signedInOrGotoAuthScreen();
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: SpinnerWidget("Authorizing"),
    );
  }
}
