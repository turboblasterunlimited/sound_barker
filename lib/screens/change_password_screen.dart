import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/the_user.dart';
import 'package:K9_Karaoke/screens/account_screen.dart';
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:K9_Karaoke/widgets/custom_dialog.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const routeName = 'change-password-screen';
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late String codeDialog;
  late String valueText;
  TextEditingController _textFieldController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  bool signingIn = false;
  late FocusNode passwordFocusNode;
  FocusNode? currentPasswordFocusNode;
  String currentPassword = "";
  String newPassword = "";
  String repeatPassword = "";

  String email = "";
  String password = "";

  bool obscurePassword = true;
  late TheUser user;
  late Map userObj;
  late BuildContext c;

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
        appBar: CustomAppBar(isMenu: false, noName: true),
        body: Container(
          padding: EdgeInsets.only(top: 60),
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
                  Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 0),
                    child: InterfaceTitleNav(
                      title: "     CHANGE PASSWORD",
                      titleSize: 20,
                      backCallback: () => Navigator.of(context)
                          .popAndPushNamed(AccountScreen.routeName),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 100.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
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
                                      ? FontAwesomeIcons.eyeSlash
                                      : FontAwesomeIcons.eye),
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
                                      ? FontAwesomeIcons.eyeSlash
                                      : FontAwesomeIcons.eye),
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
                                      ? FontAwesomeIcons.eyeSlash
                                      : FontAwesomeIcons.eye),
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
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.all(Radius.circular(22.0)),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  child: const Text("Sign In",
                                      style:TextStyle(color: Colors.white, fontSize: 20)
                                  ),
                                ),
                              ),
                              // child: FlatButton(
                              //   padding: EdgeInsets.symmetric(
                              //       vertical: 10, horizontal: 20),
                              //   child: Text("Cancel",
                              //       style: TextStyle(fontSize: fontSize)),
                              //   color: Theme.of(context).primaryColor,
                              //   onPressed: () {
                              //     Navigator.pop(context);
                              //   },
                              //   shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(22.0),
                              //   ),
                              // ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                onPressed:  isValidState()
                                    ? handleChangePassword
                                    : null,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.all(Radius.circular(22.0)),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  child: const Text("Change Password",
                                      style:TextStyle(color: Colors.white, fontSize: 20)
                                  ),
                                ),
                              ),
                              // child: FlatButton(
                              //   padding: EdgeInsets.symmetric(
                              //       vertical: 10, horizontal: 20),
                              //   child: Text("Change Password",
                              //       style: TextStyle(fontSize: fontSize)),
                              //   color: Theme.of(context).primaryColor,
                              //   onPressed: isValidState()
                              //       ? handleChangePassword
                              //       : null,
                              //   shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(22.0),
                              //   ),
                              // ),
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
