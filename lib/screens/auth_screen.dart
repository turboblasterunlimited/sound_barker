import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
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

  Future<String> authenticationLogic() async {
    var token = await authenticate(clientId, ['email', 'openid', 'profile']);
    var response = await http.post('http://165.227.178.14/openid-token/$platform',
        body: json.encode(token),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        });
    return response.body;
  }

  @override
  void initState() {
    setPlatformClientId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: FutureBuilder(
                future: authenticationLogic(),
                builder: (context, projectSnap) {
                  if (projectSnap.connectionState == ConnectionState.waiting &&
                      projectSnap.hasData == false) {
                    print('project snapshot data is: ${projectSnap.data}');
                    return Center(
                      child: Text(
                        "Wait for it...",
                        style: TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return Text(projectSnap.data);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
