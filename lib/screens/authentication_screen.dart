import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:song_barker/screens/main_screen.dart';
import 'package:song_barker/services/http_controller.dart';
import '../services/authenticate_user.dart';

class AuthenticationScreen extends StatefulWidget {
  AuthenticationScreen();

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  String clientId;
  String platform;
  bool authError = false;
  String errorString;

  void setPlatformClientId() {
    if (Platform.isAndroid) {
      clientId =
          "885484185769-05vl2rnlup9a9hdkrs78ao1jvmn1804t.apps.googleusercontent.com";
      platform = "android";
    } else if (Platform.isIOS) {
      clientId =
          "885484185769-b78ks9n5vlka0enrl33p6hkmahhg5o7i.apps.googleusercontent.com";
      platform = "ios";
    }
  }

  Future<bool> checkIfSignedIn() async {
    var response =
        await HttpController.dio.get('http://165.227.178.14/is-logged-in');
    return response.data["logged_in"];
  }

  void navigateNext() {
    Navigator.of(context).pushNamed(MainScreen.routeName);
  }

  void handleAuthentication() async {
    var token = await authenticate(clientId, ['email', 'openid', 'profile']);
    var response = await HttpController.dio.post(
      'http://165.227.178.14/openid-token/$platform',
      data: token,
    );
    if (response.data["success"]) {
      navigateNext();
    } else {
      setState(() {
        authError = true;
        errorString = response.data["error"];
      });
    }
  }

  @override
  void initState() {
    setPlatformClientId();
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    if (await checkIfSignedIn()) {
      navigateNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomPadding: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 50),
                ),
                Text(
                  "K9 Karaoke",
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                // TextField(
                //   obscureText: true,
                //   decoration: InputDecoration(
                //     filled: true,
                //     fillColor: Colors.white,
                //     border: OutlineInputBorder(),
                //     labelText: 'Email',
                //   ),
                // ),
                // TextField(
                //   obscureText: true,
                //   decoration: InputDecoration(
                //     filled: true,
                //     fillColor: Colors.white,
                //     border: OutlineInputBorder(),
                //     labelText: 'Password',
                //   ),
                // ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                GoogleSignInButton(
                  onPressed: () {
                    handleAuthentication();
                  },
                ),
                // FacebookSignInButton(
                //   onPressed: null,
                // ),
              ],
            ),
          ),
          Visibility(
            visible: !authError,
            child: Expanded(
              child: Center(
                child: SpinKitWave(
                  color: Theme.of(context).primaryColor,
                  size: 80,
                ),
              ),
            ),
          ),
          Visibility(
            visible: authError,
            child: Expanded(
              child: Column(
                children: <Widget>[
                  RawMaterialButton(
                    onPressed: handleAuthentication,
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.swap_horizontal_circle,
                          color: Colors.black38,
                          size: 30,
                        ),
                        Text("Try again"),
                      ],
                    ),
                  ),
                  Center(
                    child: Text("Error!!!\n\n$errorString"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
