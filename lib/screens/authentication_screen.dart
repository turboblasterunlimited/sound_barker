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
  bool loading = true;

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

  void handleAuthentication(context) async {
    setState(() => loading = true);
    var token = await authenticate(clientId, ['email', 'openid', 'profile']);
    var response = await HttpController.dio.post(
      'http://165.227.178.14/openid-token/$platform',
      data: token,
    );
    if (response.data["success"]) {
      navigateNext();
    } else {
      setState(() {
        loading = false;
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content:
                Text("The following error occured: ${response.data["error"]}"),
          ),
        );
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
    super.didChangeDependencies();
    if (await checkIfSignedIn()) {
      navigateNext();
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white, size: 30),
        backgroundColor: Theme.of(context).accentColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "K9 Karaoke",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 23, color: Colors.white),
        ),
      ),
      body: Builder(
        builder: (ctx) => Column(
          children: <Widget>[
            // Padding(
            //   padding: EdgeInsets.only(top: 50),
            // ),
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

            Visibility(
              visible: !loading,
              child: Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Column(
                  children: <Widget>[
                    Center(
                      child: GoogleSignInButton(
                        onPressed: () {
                          handleAuthentication(ctx);
                        },
                      ),
                    ),
                    // FacebookSignInButton(
                    //   onPressed: null,
                    // ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: loading,
              child: Center(
                child: SpinKitWave(
                  // color: Theme.of(context).primaryColor,
                  color: Colors.white,
                  size: 100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
