import 'package:K9_Karaoke/providers/the_user.dart';
import 'package:K9_Karaoke/screens/authentication_screen.dart';
import 'package:K9_Karaoke/screens/retrieve_data_screen.dart';
import 'package:K9_Karaoke/transitions/fade.dart';

import 'package:K9_Karaoke/widgets/error_dialog.dart';
import 'package:K9_Karaoke/widgets/loading_screen_widget.dart';
import 'package:K9_Karaoke/widgets/user_agreement.dart';
import 'package:flutter/material.dart';

import 'package:K9_Karaoke/services/http_controller.dart';
import 'package:flutter/services.dart';
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
  TheUser? user;
  late Map userObj;
  bool noInternet = false;
  late BuildContext c;

  // This is the same for authentication screen
  bool _agreementAccepted = false;
  bool _showAgreement = false;

  void _handleSignedIn() async {
    _agreementAccepted = userObj["user_agreed_to_terms_v1"] == 1;
    print("agreement accepted: $_agreementAccepted");
    if (!_agreementAccepted) {
      setState(() {
        _showAgreement = true;
      });
      SystemChrome.setEnabledSystemUIOverlays([]);
    } else {
      await user?.signIn(userObj);
      print("navigating to retrieve data");
      Navigator.of(context)
          .pushReplacement(FadeRoute(page: RetrieveDataScreen()));
    }
  }

  Future<void> acceptAgreement(bool isAccepted) async {
    setState(() {
      _showAgreement = false;
      _agreementAccepted = isAccepted;
    });
    if (isAccepted) {
      await user?.agreeToTerms();
      await user?.signIn(userObj);
      Navigator.of(context)
          .pushReplacement(FadeRoute(page: RetrieveDataScreen()));
    } else {
      print("agreement refused");
      Navigator.of(context).popAndPushNamed(AuthenticationScreen.routeName);
    }
  }

  // END same for authentication screen

  Future<Map> checkIfSignedIn() async {
    var response;
    try {
      response = await HttpController.dioGet('https://$serverURL/is-logged-in');
    } catch (e) {
      return {"error": e};
    }

    return response?.data;
  }

  void _handleNotSignedIn() {
    Navigator.of(context).popAndPushNamed(AuthenticationScreen.routeName);
  }

  void _handleNoInternet(error) {
    setState(() => noInternet = true);
    showError(c, error);
  }

  void signedInOrGotoAuthScreen() async {
    Map response = await checkIfSignedIn();

    // jmf - 29Dec2021: Added since this can be null and userObject must not be
    // set to null (it is late final)
    var tempUserObj = response['user_obj'];
    if (tempUserObj != null) {
      setState(() => userObj = response['user_obj']);
    }

    print("response is....: $response");
    if (response["error"] != null) {
      _handleNoInternet(response["error"]);
    } else if (response["logged_in"] != null && response["logged_in"]) {
      _handleSignedIn();
    } else {
      _handleNotSignedIn();
    }
  }

  void tryAgain() {
    setState(() => noInternet = false);
    print("about to call signedInOrGotoAuthScreen from tryAgain");
    signedInOrGotoAuthScreen();
    print("tryAgain: returned from signInOrGoToAuthScreen");
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<TheUser>(context, listen: false);

    if (firstBuild) {
      setState(() => firstBuild = false);
      print("about to call signedInOrGotoAuthScreen from first build");
      signedInOrGotoAuthScreen();
      print("returned from first build");
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: Builder(
        builder: (ctx) {
          c = ctx;
          return noInternet
              ? LoadingScreenWidget(
                  "Make sure you are connected to the internet",
                  widget: MaterialButton(
                    color: Theme.of(context).primaryColor,
                    child: Text("Try Again"),
                    onPressed: tryAgain,
                  ),
                )
              : _showAgreement
                  ? UserAgreement(acceptAgreement)
                  : LoadingScreenWidget("Authorizing");
        },
      ),
    );
  }
}
