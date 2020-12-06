import 'dart:async';
import 'dart:io' show Platform;
import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/the_user.dart';
import 'package:K9_Karaoke/screens/retrieve_data_screen.dart';
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:K9_Karaoke/widgets/custom_dialog.dart';
import 'package:K9_Karaoke/widgets/error_dialog.dart';
import 'package:K9_Karaoke/widgets/user_agreement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:openid_client/openid_client_io.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'package:K9_Karaoke/services/http_controller.dart';
import 'package:provider/provider.dart';
import '../services/authenticate_user.dart';
import 'package:K9_Karaoke/globals.dart';

class AuthenticationScreen extends StatefulWidget {
  static const routeName = 'authentication-screen';

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool signingIn = false;
  FocusNode passwordFocusNode;
  String email = "";
  String password = "";
  bool obscurePassword = true;
  TheUser user;
  BuildContext c;
  bool _showAgreement = false;
  bool _agreementAccepted = false;
  var agreementCompleter = Completer();

  void acceptAgreement(bool isAccepted) {
    setState(() {
      _showAgreement = false;
      _agreementAccepted = isAccepted;
      agreementCompleter.complete();
    });
  }

  void _showLoadingModal(Function getLoadingContext) async {
    await showDialog<Null>(
      context: context,
      builder: (ctx) {
        getLoadingContext(ctx);
        return AlertDialog(
          title: Text('Verifying...'),
          content: Container(
            height: 100,
            child: Center(
              child: SpinKitWave(color: Theme.of(context).primaryColor),
            ),
          ),
        );
      },
    );
  }

  void _showVerifyEmail() async {
    return showDialog(
        context: context,
        builder: (ctx) {
          return CustomDialog(
            header: 'Verify email address',
            bodyText:
                'Verification email sent to $email.\n\nGo to your inbox and click the link to confirm.',
            primaryFunction: (BuildContext modalContext) async {
              var response = await _handleManualSignIn();
              if (!response["success"])
                showError(c, response["error"]);
              else {
                Navigator.of(modalContext).pop();
                _handleServerResponse(response);
              }
              SystemChrome.setEnabledSystemUIOverlays([]);
            },
            primaryButtonText: "Sign In",
            secondaryButtonText: "Cancel",
            iconPrimary: Icon(
              CustomIcons.modal_mailbox,
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

  void _handleSignedIn(email) async {
    user.signIn(email);
    Navigator.of(context).popAndPushNamed(RetrieveDataScreen.routeName);
  }

  String get platform {
    if (Platform.isAndroid) {
      return "android";
    } else if (Platform.isIOS) {
      return "ios";
    }
  }

  _handleServerResponse(responseData) async {
    print("Sign in response data: $responseData");
    if (responseData["success"]) {
      print("the response data: $responseData");
      _handleSignedIn(responseData["payload"]["email"]);
    } else {
      showError(c, responseData["error"]);
    }
  }

  // ALL FACEBOOK
  _sendFacebookTokenToServer(String token) async {
    Map tokenData = {"facebook_token": token};
    try {
      var response = await HttpController.dioPost(
        'https://$serverURL/facebook-token',
        data: tokenData,
      );
      return response;
    } catch (e) {
      showError(c, "");
    }
  }

  _handleFacebookAuthentication() async {
    try {
      final facebookLogin = FacebookLogin();
      facebookLogin.currentAccessToken;
      var result = await facebookLogin.logIn(['email', 'public_profile']);
      var responseData;
      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          responseData =
              await _sendFacebookTokenToServer(result.accessToken.token);

          _handleServerResponse(responseData?.data);
          break;
        case FacebookLoginStatus.cancelledByUser:
          showError(c,
              "To sign in with Facebook, accept Facebook's permission request");
          break;
        case FacebookLoginStatus.error:
          showError(c, "Facebook credentials denied");
          break;
      }
    } catch (e) {
      // webview will inform user if no internet
    }
  }

  // ALL GOOGLE
  String getGoogleClientID() {
    if (Platform.isAndroid) {
      return "885484185769-05vl2rnlup9a9hdkrs78ao1jvmn1804t.apps.googleusercontent.com";
    } else if (Platform.isIOS) {
      return "885484185769-b78ks9n5vlka0enrl33p6hkmahhg5o7i.apps.googleusercontent.com";
    }
  }

  void _handleGoogleAuthentication() async {
    // setState(() => signingIn = true);
    var token;
    var response;
    String clientId;

    // hardcoded for google right now.
    var issuer = Issuer.google;
    clientId = getGoogleClientID();
    try {
      token =
          await authenticate(issuer, clientId, ['email', 'openid', 'profile']);
      response = await HttpController.dioPost(
        'https://$serverURL/openid-token/${platform}',
        data: token,
      );
      _handleServerResponse(response?.data);
    } catch (e) {
      showError(
        c,
      );
    }
  }

  Future _handleManualSignUp() async {
    FocusScope.of(context).unfocus();
    BuildContext loadingContext;
    _showLoadingModal((ctx) => loadingContext = ctx);
    Map response = await RestAPI.userManualSignUp(email, password);
    Navigator.of(loadingContext).pop();
    if (!response["success"])
      showError(c, response["error"]);
    else if (response["account_already_exists"] == true) {
      _handleSignedIn(response["payload"]["email"]);
    } else {
      print("Server response: $response");
      _showVerifyEmail();
    }
  }

  Future<dynamic> _handleManualSignIn() async {
    return await RestAPI.userManualSignIn(email, password);
  }

  Future<void> _handleSignInButton() async {
    FocusScope.of(context).unfocus();
    if (invalidInput)
      return showError(c, "Please enter a valid email and password");
    ;
    var response = await _handleManualSignIn();
    print("Response check: $response");
    if (!response["success"]) {
      showError(c, response["error"]);
    } else
      _handleServerResponse(response);
  }

  bool get invalidInput {
    return (email.length < 6 || password.length == 0);
  }

  Function _handleSignUp(Function signUpFunction, {bool manualSignUp = false}) {
    return () async {
      if (manualSignUp && invalidInput)
        return showError(c, "Please enter a valid email and password");

      // If agreement was not previously accepted
      if (!_agreementAccepted) {
        setState(() => _showAgreement = true);
        await agreementCompleter.future;
      }
      // Then, after showing the agreement
      if (_agreementAccepted)
        signUpFunction();
      else
        setState(() {
          _showAgreement = false;
          agreementCompleter = Completer();
        });
    };
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
    passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    user = Provider.of<TheUser>(ctx);
    double height = MediaQuery.of(ctx).size.height;
    print("Height: $height");
    double iconPadding = height > 1000 ? 100 : height / 15;
    double iconPaddingTop = height > 1000 ? 130 : 0;

    return _showAgreement
        ? UserAgreement(acceptAgreement)
        : Scaffold(
            key: _scaffoldKey,
            resizeToAvoidBottomPadding: false,
            extendBodyBehindAppBar: true,
            appBar: null,
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/backgrounds/menu_background.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Builder(builder: (BuildContext con) {
                c = con;
                return SafeArea(
                  top: false,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: iconPadding,
                            right: iconPadding,
                            top: iconPaddingTop,
                          ),
                          child: SvgPicture.asset(
                            "assets/logos/K9_logotype.svg",
                            // width: 100,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 180.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 400),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 30, right: 30, bottom: 15),
                                child: TextField(
                                  onChanged: (emailValue) {
                                    setState(() {
                                      email = emailValue;
                                    });
                                  },
                                  onSubmitted: (_) {
                                    passwordFocusNode.requestFocus();
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(),
                                    labelText: 'Email',
                                  ),
                                ),
                              ),
                            ),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 400),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30.0),
                                child: TextField(
                                  obscureText: obscurePassword,
                                  focusNode: passwordFocusNode,
                                  onChanged: (passwordValue) {
                                    setState(() => password = passwordValue);
                                  },
                                  onSubmitted: (_) {
                                    FocusScope.of(context).unfocus();
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(),
                                    labelText: 'Password',
                                    suffixIcon: GestureDetector(
                                      onTap: () => setState(() =>
                                          obscurePassword = !obscurePassword),
                                      child: Icon(obscurePassword
                                          ? LineAwesomeIcons.eye_slash
                                          : LineAwesomeIcons.eye),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ButtonBar(
                              alignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FlatButton(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    child: Text("Sign Up",
                                        style: TextStyle(fontSize: 20)),
                                    color: Theme.of(context).primaryColor,
                                    onPressed: _handleSignUp(
                                      _handleManualSignUp,
                                      manualSignUp: true,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22.0),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FlatButton(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    child: Text("Sign In",
                                        style: TextStyle(fontSize: 20)),
                                    color: Theme.of(context).primaryColor,
                                    onPressed: _handleSignInButton,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 200,
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Divider(
                                color: Colors.black,
                                thickness: 2,
                              ),
                            ),
                            Center(
                              child: GoogleSignInButton(
                                text: "Continue with Google",
                                onPressed:
                                    _handleSignUp(_handleGoogleAuthentication),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: FacebookSignInButton(
                                onPressed: _handleSignUp(
                                    _handleFacebookAuthentication),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }),
            ),
          );
  }
}
