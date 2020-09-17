import 'dart:io' show Platform;
import 'package:K9_Karaoke/providers/card_audio.dart';
import 'package:K9_Karaoke/providers/card_decoration_image.dart';
import 'package:K9_Karaoke/providers/barks.dart';
import 'package:K9_Karaoke/providers/creatable_songs.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/pictures.dart';
import 'package:K9_Karaoke/providers/songs.dart';
import 'package:K9_Karaoke/providers/user.dart';
import 'package:K9_Karaoke/screens/main_screen.dart';
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:K9_Karaoke/widgets/spinner_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:openid_client/openid_client_io.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'package:K9_Karaoke/services/http_controller.dart';
import 'package:provider/provider.dart';
import '../services/authenticate_user.dart';

class AuthenticationScreen extends StatefulWidget {
  static const routeName = '/';

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool signingIn = true;
  FocusNode passwordFocusNode;
  String email;
  String password;
  bool obscurePassword = true;

  User user;
  Barks barks;
  Songs songs;
  Pictures pictures;
  CreatableSongs creatableSongs;
  CardAudios cardAudios;
  CardDecorationImages decorationImages;
  KaraokeCards cards;

  bool everythingDownloaded = true;
  String downloadMessage = "Initializing...";

  void _showError([message = "You must be connected to the internet"]) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _showVerifyEmail() async {
    await showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Verify email address'),
        content: Text('Verification sent to $email.'),
        actions: <Widget>[
          FlatButton(
              child: Text("re-send email"),
              onPressed: () {
                Navigator.of(ctx).pop();
              }),
          FlatButton(
              child: Text('sign in'),
              onPressed: () async {
                var response = await _handleManualSignIn();
                if (!response["success"])
                  _showError(response["error"]);
                else {
                  Navigator.of(ctx).pop();
                  _handleServerResponse(response);
                }
              })
        ],
      ),
    );
  }

  Future<Map> checkIfSignedIn() async {
    try {
      return (await HttpController.dio
              .get('http://165.227.178.14/is-logged-in'))
          .data;
    } catch (e) {
      _showError();
      return {};
    }
  }

  void _handleSignedIn(email) async {
    print("handlesignedin");
    user.signIn(email);
    await downloadEverything();
    Navigator.of(context).popAndPushNamed(MainScreen.routeName);
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
      _showError(responseData["error"]);
    }
  }

  // ALL FACEBOOK
  _sendFacebookTokenToServer(String token) async {
    Map tokenData = {"facebook_token": token};
    try {
      var response = await HttpController.dio.post(
        'http://165.227.178.14/facebook-token',
        data: tokenData,
      );
      return response.data;
    } catch (e) {
      _showError("");
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
          _handleServerResponse(responseData);
          break;
        case FacebookLoginStatus.cancelledByUser:
          _showError(
              "To sign in with Facebook, accept Facebook's permission request");
          break;
        case FacebookLoginStatus.error:
          _showError("Facebook credentials denied");
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
      response = await HttpController.dio.post(
        'http://165.227.178.14/openid-token/${platform}',
        data: token,
      );
      _handleServerResponse(response);
    } catch (e) {
      _showError();
    }
  }

  Future _handleManualSignUp() async {
    FocusScope.of(context).unfocus();
    Map response = await RestAPI.userManualSignUp(email, password);
    if (!response["success"])
      _showError(response["error"]);
    else {
      _showVerifyEmail();
    }
  }

  Future<dynamic> _handleManualSignIn() async {
    return await RestAPI.userManualSignIn(email, password);
  }

  @override
  void initState() {
    super.initState();
    passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> downloadEverything() async {
    if (mounted)
      setState(() {
        everythingDownloaded = false;
        signingIn = false;
        downloadMessage = "Retrieving Pictures...";
      });
    await pictures.retrieveAll();
    print("pictures count: ${pictures.all.length}");
    // need creatableSongData to get songIds
    await creatableSongs.retrieveFromServer();
    setState(() => downloadMessage = "Retrieving Barks...");
    await barks.retrieveAll();
    songs.setCreatableSongs(creatableSongs.all);
    setState(() => downloadMessage = "Retrieving Songs...");
    await songs.retrieveAll();
    setState(() => downloadMessage = "Retrieving Cards...");
    await cardAudios.retrieveAll();
    setState(() => downloadMessage = "Retrieving Card Decorations...");
    await decorationImages.retrieveAll();
    setState(() => downloadMessage = "Retrieving Cards Themselves...");
    await cards.retrieveAll(pictures, cardAudios, songs, decorationImages);
    print("card count ${cards.all.length}");
    if (mounted) setState(() => downloadMessage = "Done.");
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    user = Provider.of<User>(context, listen: false);
    barks = Provider.of<Barks>(context, listen: false);
    songs = Provider.of<Songs>(context, listen: false);
    pictures = Provider.of<Pictures>(context, listen: false);
    creatableSongs = Provider.of<CreatableSongs>(context, listen: false);
    cardAudios = Provider.of<CardAudios>(context, listen: false);
    decorationImages =
        Provider.of<CardDecorationImages>(context, listen: false);
    cards = Provider.of<KaraokeCards>(context, listen: false);

    var responseData = await checkIfSignedIn();
    if (responseData["logged_in"]) {
      _handleSignedIn(responseData["user_id"]);
    } else {
      setState(() => signingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("building auth screen...");
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      extendBodyBehindAppBar: true,
      appBar: signingIn
          ? null
          : AppBar(
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
            ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/menu_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Visibility(
              visible: !signingIn,
              child: Padding(
                padding: const EdgeInsets.only(top: 180.0),
                child: Column(
                  children: <Widget>[
                    Padding(
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
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
                            onTap: () => setState(
                                () => obscurePassword = !obscurePassword),
                            child: Icon(obscurePassword
                                ? LineAwesomeIcons.eye_slash
                                : LineAwesomeIcons.eye),
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
                            child:
                                Text("Sign In", style: TextStyle(fontSize: 20)),
                            color: Theme.of(context).primaryColor,
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              var response = await _handleManualSignIn();
                              if (!response["success"])
                                _showError(response["error"]);
                              else
                                _handleServerResponse(response);
                            },
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
                            child:
                                Text("Sign Up", style: TextStyle(fontSize: 20)),
                            color: Theme.of(context).primaryColor,
                            onPressed: _handleManualSignUp,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 200,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(
                        color: Colors.black,
                        thickness: 2,
                      ),
                    ),
                    Center(
                      child: GoogleSignInButton(
                        text: "Continue with Google",
                        onPressed: _handleGoogleAuthentication,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: FacebookSignInButton(
                        onPressed: () {
                          _handleFacebookAuthentication();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: signingIn || !everythingDownloaded,
              child:
                  SpinnerWidget(signingIn ? "Signing in..." : downloadMessage),
            ),
          ],
        ),
      ),
    );
  }
}
