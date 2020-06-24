import 'dart:io' show Platform;
import 'package:K9_Karaoke/providers/user.dart';
import 'package:K9_Karaoke/screens/menu_screen.dart';
import 'package:K9_Karaoke/widgets/spinner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

import 'package:K9_Karaoke/services/http_controller.dart';
import 'package:provider/provider.dart';
import '../services/authenticate_user.dart';

class AuthenticationScreen extends StatefulWidget {
  static const routeName = 'authentication-screen';
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

  Future<Map> checkIfSignedIn() async {
    var response =
        await HttpController.dio.get('http://165.227.178.14/is-logged-in');
    print("response data: $response");
    return response.data;
  }

  void handleSignedIn(email) {
    print("Sign-in successful email: $email");
    Provider.of<User>(context, listen: false).signIn(email);
    Navigator.of(context).pushReplacementNamed(MenuScreen.routeName);
  }

  void handleAuthentication() async {
    setState(() => loading = true);
    var token = await authenticate(clientId, ['email', 'openid', 'profile']);
    var response = await HttpController.dio.post(
      'http://165.227.178.14/openid-token/$platform',
      data: token,
    );
    print("Sign in response data: ${response.data}");
    if (response.data["success"]) {
      print("the response data: ${response.data}");
      handleSignedIn(response.data["payload"]["email"]);
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
    var responseData = await checkIfSignedIn();
    print("reeeeesponse data: ${responseData}");
    if (responseData["logged_in"]) {
      print("it's true");
      handleSignedIn(responseData["user_id"]);
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    print("building auth screen...");
    return Scaffold(
      backgroundColor: Colors.amber[50],
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white, size: 30),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "K-9 Karaoke",
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
                          handleAuthentication();
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
              child: SpinnerWidget("Signing in..."),
            ),
          ],
        ),
      ),
    );
  }
}
