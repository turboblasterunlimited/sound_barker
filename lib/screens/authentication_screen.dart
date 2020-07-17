import 'dart:io' show Platform;
import 'package:K9_Karaoke/providers/barks.dart';
import 'package:K9_Karaoke/providers/pictures.dart';
import 'package:K9_Karaoke/providers/songs.dart';
import 'package:K9_Karaoke/providers/user.dart';
import 'package:K9_Karaoke/screens/main_screen.dart';
import 'package:K9_Karaoke/widgets/spinner_widget.dart';
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
  Function callback;
  AuthenticationScreen([this.callback]);

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  bool loading = true;
  FocusNode passwordFocusNode;
  String email;
  String password;
  bool obscurePassword = true;

  User user;
  Barks barks;
  Songs songs;
  Pictures pictures;
  bool everythingDownloaded = true;

  void _showError(message) {
    setState(() {
      loading = false;
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("The following error occured: $message"),
        ),
      );
    });
  }

  Future<Map> checkIfSignedIn() async {
    var response =
        await HttpController.dio.get('http://165.227.178.14/is-logged-in');
    return response.data;
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

  handleServerResponse(responseData) async {
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
    var response = await HttpController.dio.post(
      'http://165.227.178.14/facebook-token',
      data: tokenData,
    );
    return response.data;
  }

  handleFacebookAuthentication() async {
    final facebookLogin = FacebookLogin();
    facebookLogin.currentAccessToken;
    var result = await facebookLogin.logIn(['email', 'public_profile']);
    var responseData;
    print("Result you want: ${result.status}");
    print("access token: ${result.accessToken.token}");
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        responseData =
            await _sendFacebookTokenToServer(result.accessToken.token);
        handleServerResponse(responseData);
        break;
      case FacebookLoginStatus.cancelledByUser:
        _showError(
            "To sign in with Facebook, accept Facebook's permission request");
        break;
      case FacebookLoginStatus.error:
        _showError("Facebook credentials denied");
        break;
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

  void handleGoogleAuthentication() async {
    setState(() => loading = true);
    var token;
    var response;
    String clientId;

    // hardcoded for google right now.
    var issuer = Issuer.google;

    clientId = getGoogleClientID();
    token =
        await authenticate(issuer, clientId, ['email', 'openid', 'profile']);
    response = await HttpController.dio.post(
      'http://165.227.178.14/openid-token/${platform}',
      data: token,
    );
    handleServerResponse(response.data);
  }

  void _handleManualSignUp() async {
    var response;
    Map data = {"email": email, "password": password};
    print("before sending sign up: $data");
    response = await HttpController.dio.post(
      'http://165.227.178.14/create-account',
      data: data,
    );
    print(response);
    handleServerResponse(response.data);
  }

  void _handleManualSignIn() async {
    var response;
    Map data = {"email": email, "password": password};
    print("before sending sign in: $data");
    response = await HttpController.dio.post(
      'http://165.227.178.14/manual-login',
      data: data,
    );
    print(response);
    handleServerResponse(response.data);
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
    setState(() {
      everythingDownloaded = false;
      loading = false;
    });
    await pictures.retrieveAll();
    // need creatableSongData to get songIds
    await songs.retrieveCreatableSongsData();
    await barks.retrieveAll();
    await songs.retrieveAll();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    user = Provider.of<User>(context, listen: false);
    barks = Provider.of<Barks>(context, listen: false);
    songs = Provider.of<Songs>(context, listen: false);
    pictures = Provider.of<Pictures>(context, listen: false);

    var responseData = await checkIfSignedIn();
    if (responseData["logged_in"]) {
      _handleSignedIn(responseData["user_id"]);
    } else {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("building auth screen...");
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      extendBodyBehindAppBar: true,
      appBar: loading
          ? null
          : PreferredSize(
              preferredSize: Size.fromHeight(60.0),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading:
                    false, // Don't show the leading button
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset("assets/logos/K9_logotype.png", width: 100),
                  ],
                ),
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
              visible: !loading,
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
                            onPressed: () {
                              _handleManualSignIn();
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
                            onPressed: () {
                              _handleManualSignUp();
                            },
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
                        onPressed: () {
                          handleGoogleAuthentication();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: FacebookSignInButton(
                        onPressed: () {
                          handleFacebookAuthentication();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: loading || !everythingDownloaded,
              child: SpinnerWidget(
                  loading ? "Signing in..." : "Getting your stuff!"),
            ),
          ],
        ),
      ),
    );
  }
}
