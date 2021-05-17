import 'dart:async';
import 'dart:io' show Platform;
import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/the_user.dart';
import 'package:K9_Karaoke/screens/retrieve_data_screen.dart';
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:K9_Karaoke/widgets/custom_appbar.dart';
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

class ChangePasswordScreen extends StatefulWidget {
  static const routeName = 'change-password-screen';
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  String codeDialog;
  String valueText;
  TextEditingController _textFieldController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool signingIn = false;
  FocusNode passwordFocusNode;
  FocusNode currentPasswordFocusNode;
  String currentPassword = "";
  String newPassword = "";
  String repeatPassword = "";

  String email = "";
  String password = "";

  bool obscurePassword = true;
  TheUser user;
  Map userObj;
  BuildContext c;

  final double fontSize = 20;

  bool isValidRequest() {
    var isValid = true;

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        repeatPassword.isEmpty) {
      isValid = false;
    } else if (newPassword != repeatPassword) {
      isValid = false;
    }

    return isValid;
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

  bool isValidState() {
    bool notEmpty = currentPassword.isNotEmpty &&
        newPassword.isNotEmpty &&
        repeatPassword.isNotEmpty;
    return notEmpty && newPassword == repeatPassword;
  }

  void displayResultsChangePassword(context, msg) async {
    return showDialog(
        context: context,
        builder: (ctx) {
          return CustomDialog(
            header: 'Change Password',
            bodyText: msg,
            primaryFunction: (BuildContext modalContext) async {
              Navigator.of(modalContext).pop();
              SystemChrome.setEnabledSystemUIOverlays([]);
            },
            primaryButtonText: "OK",
            iconPrimary: Icon(
              CustomIcons.modal_paws_bottomright,
              size: 42,
              color: Colors.grey[300],
            ),
            iconSecondary: Icon(
              CustomIcons.modal_paws_topleft,
              size: 42,
              color: Colors.grey[300],
            ),
            oneButton: true,
            isYesNo: false,
          );
        });
  }

  void handleChangePassword() async {
    Map map = await RestAPI.userChangePassword(currentPassword, newPassword);
    String msg = map['success'] ? 'Password changed.' : map['error'];
    print("handleChangePassword: " + msg);
    displayResultsChangePassword(context, msg);
  }

  @override
  Widget build(BuildContext ctx) {
    user = Provider.of<TheUser>(ctx);
    double height = MediaQuery.of(ctx).size.height;
    double iconPadding = height > 1000 ? 100 : height / 15;
    double iconPaddingTop = height > 1000 ? 130 : 0;

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(isMenu: false, pageTitle: "Change Password"),
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
                  // Positioned(
                  //   left: 0,
                  //   right: 0,
                  //   top: 20,
                  //   child: Padding(
                  //     padding: EdgeInsets.only(
                  //       left: iconPadding,
                  //       right: iconPadding,
                  //       top: iconPaddingTop,
                  //     ),
                  //     child: SvgPicture.asset(
                  //       "assets/logos/K9_logotype.svg",
                  //       // width: 100,
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 400),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 30, right: 30, bottom: 15),
                            child: TextField(
                              obscureText: obscurePassword,
                              focusNode: currentPasswordFocusNode,
                              onChanged: (value) {
                                setState(() {
                                  currentPassword = value;
                                });
                              },
                              onSubmitted: (_) {
                                FocusScope.of(context).unfocus();
                                SystemChrome.setEnabledSystemUIOverlays([]);
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(),
                                labelText: 'Current Password',
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
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 400),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 30, right: 30, bottom: 15),
                            child: TextField(
                              obscureText: obscurePassword,
                              focusNode: currentPasswordFocusNode,
                              onChanged: (value) {
                                setState(() {
                                  newPassword = value;
                                });
                              },
                              onSubmitted: (_) {
                                FocusScope.of(context).unfocus();
                                SystemChrome.setEnabledSystemUIOverlays([]);
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(),
                                labelText: 'New Password',
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
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 400),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            child: TextField(
                              obscureText: obscurePassword,
                              focusNode: passwordFocusNode,
                              onChanged: (passwordValue) {
                                setState(() => repeatPassword = passwordValue);
                              },
                              onSubmitted: (_) {
                                FocusScope.of(context).unfocus();
                                SystemChrome.setEnabledSystemUIOverlays([]);
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(),
                                labelText: 'Repeat New Password',
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
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 0),
                              child: FlatButton(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: Text("Cancel",
                                    style: TextStyle(fontSize: fontSize)),
                                color: Theme.of(context).primaryColor,
                                onPressed: () {
                                  Navigator.pop(context);
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
                                child: Text("Change Password",
                                    style: TextStyle(fontSize: fontSize)),
                                color: Theme.of(context).primaryColor,
                                onPressed: isValidState()
                                    ? handleChangePassword
                                    : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
