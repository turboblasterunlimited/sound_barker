import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:song_barker/screens/main_screen.dart';
import '../functions/authenticate_user.dart';
import 'package:http/http.dart' as http;

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

  Future<String> handleAuthentication() async {
    var token = await authenticate(clientId, ['email', 'openid', 'profile']);
    var response = await http.post(
        'http://165.227.178.14/openid-token/$platform',
        body: json.encode(token),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        });
    Map responseMap = json.decode(response.body);
    if (responseMap["success"]) {
      Navigator.of(context).pushNamed(MainScreen.routeName);
    } else {
      setState(() {
        authError = true;
        errorString = responseMap["error"];
      });
    }
  }

  @override
  void initState() {
    setPlatformClientId();
    super.initState();
    handleAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
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
              child: Center(
                child: Text("Error!!!\n\n$errorString"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
