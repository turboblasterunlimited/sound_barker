import 'dart:io' show Platform;
import 'package:K9_Karaoke/providers/user.dart';
import 'package:K9_Karaoke/widgets/spinner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:openid_client/openid_client_io.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'package:K9_Karaoke/services/http_controller.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';
import '../services/authenticate_user.dart';

class AuthenticationScreen extends StatefulWidget {
  Function callback;
  static const routeName = 'authentication-screen';
  AuthenticationScreen(this.callback);

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  bool loading = true;

  void _showError(message) {
    setState(() {
        loading = false;
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content:
                Text("The following error occured: $message"),
          ),
        );
      });
  }

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
        responseData = await _sendFacebookTokenToServer(result.accessToken.token);
        handleServerResponse(responseData);
        break;
      case FacebookLoginStatus.cancelledByUser:
        _showError("To sign in with Facebook, accept Facebook's permission request");
        break;
      case FacebookLoginStatus.error:
        _showError("Facebook credentials denied");
        break;
    }
  }

  String getGoogleClientID() {
    if (Platform.isAndroid) {
      return "885484185769-05vl2rnlup9a9hdkrs78ao1jvmn1804t.apps.googleusercontent.com";
    } else if (Platform.isIOS) {
      return "885484185769-b78ks9n5vlka0enrl33p6hkmahhg5o7i.apps.googleusercontent.com";
    }
  }

  Future<Map> checkIfSignedIn() async {
    var response =
        await HttpController.dio.get('http://165.227.178.14/is-logged-in');
    return response.data;
  }

  void handleSignedIn(email) {
    Provider.of<User>(context, listen: false).signIn(email);
    widget.callback();
    Navigator.of(context).pop();
  }

  String get platform {
    if (Platform.isAndroid) {
      return "android";
    } else if (Platform.isIOS) {
      return "ios";
    }
  }

  handleServerResponse(responseData) {
    print("Sign in response data: $responseData");
    if (responseData["success"]) {
      print("the response data: $responseData");
      handleSignedIn(responseData["payload"]["email"]);
    } else {
      _showError(responseData["error"]);
    }
  }

  void handleGoogleAuthentication() async {
    setState(() => loading = true);
    var token;
    var response;
    String clientId;

    // hardcoded for google right now.
    var issuer = Issuer.google;

    if (issuer == Issuer.facebook) {
      clientId = "2622706171384608";
      token = await authenticate(issuer, clientId, ['email', 'public_profile']);
      response = await HttpController.dio.post(
        'http://165.227.178.14/facebook-token',
        data: token,
      );
    } else if (issuer == Issuer.google) {
      clientId = getGoogleClientID();
      token =
          await authenticate(issuer, clientId, ['email', 'openid', 'profile']);
      response = await HttpController.dio.post(
        'http://165.227.178.14/openid-token/${platform}',
        data: token,
      );
    }
    handleServerResponse(response.data);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    var responseData = await checkIfSignedIn();
    if (responseData["logged_in"]) {
      handleSignedIn(responseData["user_id"]);
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    print("building auth screen...");
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/backgrounds/create_background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
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
        body: Builder(
          builder: (ctx) => Column(
            children: <Widget>[
              Visibility(
                visible: !loading,
                child: Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 30, right: 30, bottom: 15),
                        child: TextField(
                          obscureText: true,
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
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            labelText: 'Password',
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
                              child: Text("Sign In",
                                  style: TextStyle(fontSize: 20)),
                              color: Theme.of(context).primaryColor,
                              onPressed: () {},
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
                              child: Text("Sign Up",
                                  style: TextStyle(fontSize: 20)),
                              color: Theme.of(context).primaryColor,
                              onPressed: () {},
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
                visible: loading,
                child: SpinnerWidget("Signing in..."),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
