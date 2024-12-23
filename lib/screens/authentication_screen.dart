import 'dart:async';
import 'dart:io' show Platform;
import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/the_user.dart';
import 'package:K9_Karaoke/screens/retrieve_data_screen.dart';
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:K9_Karaoke/widgets/custom_dialog.dart';
import 'package:K9_Karaoke/widgets/error_dialog.dart';
import 'package:K9_Karaoke/widgets/user_agreement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: import_of_legacy_library_into_null_safe
// import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openid_client/openid_client_io.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import '../providers/flutter_facebook_login.dart';

import 'package:K9_Karaoke/services/http_controller.dart';
import 'package:provider/provider.dart';
import '../services/authenticate_user.dart';
import 'package:K9_Karaoke/globals.dart';
import 'package:email_validator/email_validator.dart';

// added jmf 19-dec-22
import '../widgets/info_popup.dart';

// added jmf 25-oct-22
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// added jmf 7-7-22
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthenticationScreen extends StatefulWidget {
  static const routeName = 'authentication-screen';

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  late final VoidCallback
      onPressed; // jmf - 22-12-21: changed to VoidCallback for null saftey changes
  bool signingIn = false;
  FocusNode? passwordFocusNode;
  String email = "";
  String password = "";
  bool obscurePassword = true;
  TheUser? user;
  Map? userObj;
  BuildContext? c;
  bool _showAgreement = false;
  bool _agreementAccepted = false;

// added jmf -- forgot password state
  TextEditingController _textFieldController = TextEditingController();
  String? forgotPasswordEmail;
  String? valueText;

  void _showErrorDialog(BuildContext context, String message, [String title = "Network Error"]) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Expanded(
                child:Text(message)
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

  void _displayInfo(BuildContext context, String title, String message) async {
    return showDialog(
        context: context,
        builder: (ctx) {
          return CustomDialog(
            header: title,
            bodyText: message,
            primaryFunction:(BuildContext modalContext) { Navigator.of(modalContext).pop();},
            primaryButtonText: "Ok",
            iconPrimary: Icon(
              CustomIcons.modal_paws_topleft,
              size: 42,
              color: Colors.grey[300],
            ),
            iconSecondary:Icon(
              CustomIcons.modal_paws_topleft,
              size: 42,
              color: Colors.grey[300],
            ),
            isYesNo: false,
            oneButton: true,
          );
        });
  }

  void _displayResetPasswordInstructions(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (ctx) {
          return CustomDialog(
            header: 'Verify email address',
            bodyText:
                'Reset email sent to $forgotPasswordEmail.\n\nGo to your inbox and click the link to reset password.',
            primaryFunction: (BuildContext modalContext) async {
              var response = await _handleManualSignIn(success: () {
                Navigator.of(modalContext).pop();
                SystemChrome.setEnabledSystemUIOverlays([]);
              });
            },
            primaryButtonText: "Sign In",
            secondaryButtonText: "Cancel",
            iconPrimary: Icon(
              CustomIcons.modal_mailbox,
              size: 42,
              color: Colors.grey[300],
            ),
            iconSecondary: Icon(
              CustomIcons.modal_paws_topleft,
              size: 42,
              color: Colors.grey[300],
            ),
            isYesNo: true,
          );
        });
  }

  Future<void> _displayForgotPasswordDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Recover Password'),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            content: Container(
              height: 150,
              child: Stack(
                children: <Widget>[
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        valueText = value;
                      });
                    },
                    controller: _textFieldController,
                    decoration: InputDecoration(
                        hintText: "Email address you signed up with."),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Icon(
                      CustomIcons.modal_paws_topleft,
                      size: 42,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor:Colors.red,
                  foregroundColor: Colors.white,
                ),
                // color: Colors.red,
                // textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor:Colors.red,
                  foregroundColor: Colors.white,
                ),
                //color: Colors.blue,
                //textColor: Colors.white,
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    forgotPasswordEmail = valueText;
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  void _handleForgotPassword() async {
    print("_handleForgotPassword");
    await _displayForgotPasswordDialog(context);
    print("email: " + forgotPasswordEmail!);
    if (forgotPasswordEmail!.isNotEmpty) {
      Map result = await RestAPI.userForgotPassword(forgotPasswordEmail);
      print("\n\n\n\n");
      print(result['success']);
      _displayResetPasswordInstructions(context);
    } else {
      print("Null email for forgot password");
    }
  }

  Future<void> acceptAgreement(bool isAccepted) async {
    setState(() {
      _showAgreement = false;
      _agreementAccepted = isAccepted;
    });
    if (isAccepted) {
      await user!.agreeToTerms();
      await user!.signIn(userObj!);
      Navigator.of(context).popAndPushNamed(RetrieveDataScreen.routeName);
    } else {
      print("agreement refused");
    }
  }

  void _showLoadingModal(Function getLoadingContext) async {
    await showDialog<Null>(
      context: context,
      builder: (ctx) {
        getLoadingContext(ctx);
        return AlertDialog(
          title: Text('Verifying...'),
          content: Container(
            height: 100,
            child: Center(
              child: SpinKitWave(color: Theme.of(context).primaryColor),
            ),
          ),
        );
      },
    );
  }

  void _showVerifyEmail() async {
    return showDialog(
        context: context,
        builder: (ctx) {
          return CustomDialog(
            header: 'Verify email address',
            bodyText:
                'Verification email sent to $email.\n\nGo to your inbox and click the link to confirm.',
            primaryFunction: (BuildContext modalContext) async {
              var response = await _handleManualSignIn(success: () {
                Navigator.of(modalContext).pop();
                SystemChrome.setEnabledSystemUIOverlays([]);
              });
            },
            primaryButtonText: "Sign In",
            secondaryButtonText: "Cancel",
            iconPrimary: Icon(
              CustomIcons.modal_mailbox,
              size: 42,
              color: Colors.grey[300],
            ),
            iconSecondary: Icon(
              CustomIcons.modal_paws_topleft,
              size: 42,
              color: Colors.grey[300],
            ),
            isYesNo: true,
          );
        });
  }

  void _handleSignedIn() async {
    print("user email from handle signed in: $email");
    _agreementAccepted = userObj!["user_agreed_to_terms_v1"] == 1;
    if (!_agreementAccepted) {
      setState(() {
        _showAgreement = true;
      });
      SystemChrome.setEnabledSystemUIOverlays([]);
    } else {
      user!.signIn(userObj!);
      Navigator.of(context).popAndPushNamed(RetrieveDataScreen.routeName);
    }
  }

  String? get platform {
    if (Platform.isAndroid) {
      return "android";
    } else if (Platform.isIOS) {
      return "ios";
    }
  }

  _handleSigninResponse(responseData) async {
    setState(() => userObj = responseData["user"]);
    print("Sign in response data: $responseData");
    if (responseData["success"]) {
      print("the response data: $responseData");
      _handleSignedIn();
    } else {
      //showError(c!, responseData["error"]);
      _showErrorDialog(c!, responseData['error'], "Sign In Error");
    }
  }

  // ALL FACEBOOK
  _sendFacebookTokenToServer(String token) async {
    Map tokenData = {"facebook_token": token};
    try {
      var response = await HttpController.dioPost(
        'https://$serverURL/facebook-token',
        data: tokenData,
      );
      return response;
    } catch (e) {
      showError(c!, "");
    }
  }

  Future<bool> _handleFacebookAuthentication() async {
    try {
      final facebookLogin = FacebookLogin();
      facebookLogin.currentAccessToken;
      var result = await facebookLogin.logIn(['email', 'public_profile']);
      var responseData;
      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          responseData =
              await _sendFacebookTokenToServer(result.accessToken!.token);
          _handleSigninResponse(responseData?.data);
          break;
        case FacebookLoginStatus.cancelledByUser:
          showError(c!,
              "To sign in with Facebook, accept Facebook's permission request");
          break;
        case FacebookLoginStatus.error:
          showError(c!, "Facebook credentials denied");
          break;
      }
    } catch (e) {
      // webview will inform user if no internet
      print(e);
    }
    return true;
  }

  // ALL GOOGLE
  String getGoogleClientID() {
    if (Platform.isAndroid) {
      return "867304541572-79nvntdsqfk463hn6cev8pls8jg64fid.apps.googleusercontent.com";
//      return "885484185769-05vl2rnlup9a9hdkrs78ao1jvmn1804t.apps.googleusercontent.com";
    } else if (Platform.isIOS) {
      return "885484185769-b78ks9n5vlka0enrl33p6hkmahhg5o7i.apps.googleusercontent.com";
    } else {
      return "";
    }
  }

  // jmf - 12-22-21: Added exception handling for null id.
  Future<bool> _handleGoogleAuthentication() async {
    // setState(() => signingIn = true);
    var token;
    var response;
    String clientId;

    // jmf - 25-oct-22, new google signin
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(scopes: <String>["email"]).signIn();

      print(googleUser);

      print("google signin");
      if(googleUser == null) {
        throw new Exception("No google user");
      }

      // Obtain the auth details from the list of google accounts
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      if(googleAuth == null) {
        throw new Exception("Couldn't authenticate google user");
      }

      Map data = {
        "id_token": googleAuth.idToken
      };
      response = await HttpController.dioPost(
        'https://$serverURL/openid-token/$platform',
        data: data,
      );
      _handleSigninResponse(response?.data);
    }
    catch (e) {
      print("Exception caught by K9: " + e.toString());
      // showError(
      //   c!,
      // );

      _showErrorDialog(c!, e.toString(), "Google sign-in error");
    }
    return true;
    // Create a new credential
    // final credential = GoogleAuthProvider.credential(
    //   accessToken: googleAuth.accessToken,
    //   idToken: googleAuth.idToken,
    // );


    // old google signin
    // hardcoded for google right now.
    // var issuer = Issuer.google;
    // try {
    //   clientId = getGoogleClientID();
    //   if (clientId.isEmpty) {
    //     throw new Exception("No Google ClientId");
    //   }
    //   token =
    //       await authenticate(issuer, clientId, ['email', 'openid', 'profile']);
    //   response = await HttpController.dioPost(
    //     'https://$serverURL/openid-token/$platform',
    //     data: token,
    //   );
    //   _handleSigninResponse(response?.data);
    // } catch (e) {
    //   print("Exception caught by K9: " + e.toString());
    //   showError(
    //     c!,
    //   );
    // }
  }

  // jmf 7-7-22: Add Apple Signaturer
  Future _handleAppleSignIn() async {
    // FocusScope.of(context).unfocus();
    // late BuildContext loadingContext;
    // _showLoadingModal((ctx) => loadingContext = ctx);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      print(credential);

      // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
      // after they have been validated with Apple (see `Integration` section for more information on how to do this)

      // Create a newvar email = (credential.email != null ? credential.email : "")!;

      Map response = await RestAPI.appleSignUp(credential.authorizationCode,
          credential.userIdentifier, credential.email, "Canine Friend");
      var userObj = response["user"];
      print("USER OBJECT: $userObj");
//      Navigator.of(loadingContext).pop();
      if (!response["success"]) {
        showError(c!, response["error"]);
      } else {
        _handleSigninResponse(response);
      }
    } catch (e) {
      print(e);
    }
  }

  Future _handleManualSignUp() async {
    FocusScope.of(context).unfocus();
    late BuildContext loadingContext;
    _showLoadingModal((ctx) => loadingContext = ctx);
    Map response = await RestAPI.userManualSignUp(email, password);
    var userObj = response["user"];
    print("USER OBJECT: $userObj");
    Navigator.of(loadingContext).pop();
    if (!response["success"]) {
      var message = response["error"].toString().contains("account already exists, but was created with openid")
                      ? "Account created with Google Sign-In.  Please sign in with Google to access your account"
                      : response["error"];
      _showErrorDialog(c!, message, "Sign In Error");
      //showError(c!, response["error"]);
    }
    else if (response["account_already_exists"] == true) {
      await _handleManualSignIn();
    } else {
      print("Server response: $response");
      _showVerifyEmail();
    }
  }



  Future _handleResendConfirmationEmail() async {
    FocusScope.of(context).unfocus();
    late BuildContext loadingContext;
    _showLoadingModal((ctx) => loadingContext = ctx);
    Map response = await RestAPI.userResendConfirmationEmail(email);
    var userObj = response["user"];
    print("USER OBJECT: $userObj");
    Navigator.of(loadingContext).pop();
    if (!response["success"])
      showError(c!, response["error"]);
    else if (response["account_already_exists"] == true) {
      await _handleManualSignIn();
    } else {
      print("Server response: $response");
      _showVerifyEmail();
    }
  }

  Future<dynamic> _handleManualSignIn({Function? success}) async {
    var response = await RestAPI.userManualSignIn(email, password);
    print("Response check: $response");
    if (!response["success"]) {
      showError(c!, response["error"]);
    } else {
      if (success != null) {
        success.call();
      }
      _handleSigninResponse(response);
    }
  }

  Future<dynamic>_handlePreview({Function? success}) async {
    var response = await RestAPI.userManualSignIn("support@turboblasterunlimited.com", "k9karaoke");
    print("Response check: $response");
    if (!response["success"]) {
      showError(c!, response["error"]);
    } else {
      if (success != null) {
        success.call();
      }
      _handleSigninResponse(response);
    }
  }

  Future<void> _handleSignInButton() async {
    FocusScope.of(context).unfocus();
    if (invalidInput)
      return showError(c!, "Please enter a valid email and password");
    _handleManualSignIn();
  }

  VoidCallback _handlePreviewButton()  {
    return () async {
      _handlePreview();
    };
    // return () {
    //  _displayInfo(context, "Function not available to Guests.", "hello everybody");
    // };
    // return () {
    //   InfoPopup.displayInfo(context, "Function not available to Guests.", "hello everybody");
    // };
  }

  bool get invalidInput {
    return (!isValidEmail || password.length == 0);
//    return (email.length < 6 || password.length == 0);
  }

  // jmf - 24-1-22: check for invalid input
  bool get isValidEmail {
    return EmailValidator.validate(email.toLowerCase());
  }

  // jmf - 22-12-21: changed to VoidCallback for null saftey changes
  VoidCallback _handleSignUp(Function signUpFunction,
      {bool manualSignUp = false}) {
    return () async {
      if (manualSignUp && invalidInput) {
        showError(c!, "Please enter a valid email and password");
      } else
        signUpFunction();
    };
  }

  VoidCallback _handResendButton(Function sendReconfirmationFunction,
      {bool manualSignUp = false}) {
    return () async {
      if (!isValidEmail) {
        showError(c!, "Please enter a valid email");
      } else
        sendReconfirmationFunction();
    };
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
    passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    passwordFocusNode!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    user = Provider.of<TheUser>(ctx);
    double height = MediaQuery.of(ctx).size.height;
    double iconPadding = height > 1000 ? 100 : height / 15;
    double iconPaddingTop = height > 1000 ? 130 : 0;
    const largeScreenLogoOffset = 430.0;
    const normalScreenLogoOffset = 200.0;
//    print("PLATFORM ===============> " + Platform.operatingSystem);
    return SafeArea(
      child: _showAgreement
          ? UserAgreement(acceptAgreement)
          : Scaffold(
              key: _scaffoldKey,
              resizeToAvoidBottomInset: true,
              extendBodyBehindAppBar: true,
              appBar: null,
              body: SingleChildScrollView(
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:
                          AssetImage("assets/backgrounds/menu_background.png"),
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
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: iconPadding,
                                right: iconPadding,
                                top: iconPaddingTop,
                              ),
                              child: SvgPicture.asset(
                                "assets/logos/K9_logotype.svg",
                                // width: 100,
                              ),
                            ),
                          ),
                          Padding(
                            padding: height > 1000
                                ? const EdgeInsets.only(
                                    top: largeScreenLogoOffset)
                                : const EdgeInsets.only(
                                    top: normalScreenLogoOffset),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 400),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30, right: 30, bottom: 15),
                                      child: TextField(
                                        onChanged: (emailValue) {
                                          setState(() {
                                            email = emailValue;
                                          });
                                        },
                                        onSubmitted: (_) {
                                          passwordFocusNode!.requestFocus();
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(),
                                          labelText: 'Email',
                                        ),
                                      ),
                                    ),
                                  ),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth: 400, maxHeight: 100),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30.0),
                                      child: TextField(
                                        obscureText: obscurePassword,
                                        focusNode: passwordFocusNode,
                                        onChanged: (passwordValue) {
                                          setState(
                                              () => password = passwordValue);
                                        },
                                        onSubmitted: (_) {
                                          FocusScope.of(context).unfocus();
                                          SystemChrome
                                              .setEnabledSystemUIOverlays([]);
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(),
                                          labelText: 'Password',
                                          suffixIcon: GestureDetector(
                                            onTap: () => setState(() =>
                                                obscurePassword =
                                                    !obscurePassword),
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
                                        padding: const EdgeInsets.all(4.0),
                                        child: TextButton(
                                          onPressed:_handleSignUp(
                                                _handleManualSignUp,
                                                manualSignUp: true,
                                              ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor,
                                              borderRadius: BorderRadius.all(Radius.circular(22.0)),
                                           ),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 10),
                                            child: const Text("Sign In/Sign Up",
                                                          style:TextStyle(color: Colors.white, fontSize: 14)),
                                          ),
                                        ),
                                      ),
                                      // Padding(
                                      //   padding: const EdgeInsets.all(4.0),
                                      //   child: TextButton(
                                      //     onPressed:_handleSignUp(
                                      //       _handleManualSignUp,
                                      //       manualSignUp: true,
                                      //     ),
                                      //     child: Container(
                                      //       decoration: BoxDecoration(
                                      //         color: Theme.of(context).primaryColor,
                                      //         borderRadius: BorderRadius.all(Radius.circular(22.0)),
                                      //       ),
                                      //       padding: EdgeInsets.symmetric(
                                      //           vertical: 10, horizontal: 10),
                                      //       child: const Text("Sign In",
                                      //           style:TextStyle(color: Colors.white, fontSize: 20)
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: TextButton(
                                          onPressed: _handlePreviewButton(),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor,
                                              borderRadius: BorderRadius.all(Radius.circular(22.0)),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 10),
                                            child: const Text("Sign in as Guest",
                                                style:TextStyle(color: Colors.white, fontSize: 14)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  ButtonBar(
                                      alignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextButton(
                                            onPressed: _handleForgotPassword,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).primaryColor,
                                                borderRadius: BorderRadius.all(Radius.circular(22.0)),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 5, horizontal: 10),
                                              child: const Text("Forgot Password",
                                                  style:TextStyle(color: Colors.white, fontSize: 14)),
                                            ),
                                          ),
                                          // child: FlatButton(
                                          //   padding: EdgeInsets.symmetric(
                                          //       vertical: 5, horizontal: 10),
                                          //   child: Text("Forgot Password",
                                          //       style: TextStyle(fontSize: 14)),
                                          //   color:
                                          //       Theme.of(context).primaryColor,
                                          //   onPressed: _handleForgotPassword,
                                          //   shape: RoundedRectangleBorder(
                                          //     borderRadius:
                                          //         BorderRadius.circular(22.0),
                                          //   ),
                                          // ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                            child: TextButton(
                                              onPressed: _handleForgotPassword,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).primaryColor,
                                                  borderRadius: BorderRadius.all(Radius.circular(22.0)),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 5, horizontal: 10),
                                                child: const Text("Resend Confirm Email",
                                                    style:TextStyle(color: Colors.white, fontSize: 14)),
                                              ),
                                          // child: FlatButton(
                                          //   padding: EdgeInsets.symmetric(
                                          //       vertical: 5, horizontal: 10),
                                          //   child: Text("Resend Confirm Email",
                                          //       style: TextStyle(fontSize: 14)),
                                          //   color:
                                          //       Theme.of(context).primaryColor,
                                          //   onPressed: _handResendButton(
                                          //       _handleResendConfirmationEmail),
                                          //   shape: RoundedRectangleBorder(
                                          //     borderRadius:
                                          //         BorderRadius.circular(22.0),
                                          //   ),
                                          // ),
                                        ),
                                        ),
                                      ]),
                                  Container(
                                    width: 200,
                                    padding:
                                        EdgeInsets.only(top: 10, bottom: 15),
                                    child: Divider(
                                      color: Colors.black,
                                      thickness: 2,
                                    ),
                                  ),
                                  Center(
                                    child: GoogleAuthButton(
                                      text: "Continue with Google",
                                      onPressed: _handleSignUp(
                                          _handleGoogleAuthentication
                                      ),
                                    ),
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.only(top: 15.0),
                                  //   child: FacebookAuthButton(
                                  //     onPressed: _handleSignUp(
                                  //         _handleFacebookAuthentication),
                                  //   ),
                                  // ),
                                  if (Platform.operatingSystem == "ios") Padding(
                                    padding: const EdgeInsets.only(top: 15.0),
                                    // child: SignInWithAppleButton(
                                    //   onPressed: () async {
                                    //     final credential = await SignInWithApple
                                    //         .getAppleIDCredential(
                                    //       scopes: [
                                    //         AppleIDAuthorizationScopes.email,
                                    //         AppleIDAuthorizationScopes.fullName,
                                    //       ],

                                    //       // TODO: Remove these if you have no need for them
                                    //       nonce: 'example-nonce',
                                    //       state: 'example-state',
                                    //     );

                                    //     // ignore: avoid_print
                                    //     print(credential);

                                    //     // This is the endpoint that will convert an authorization code obtained
                                    //     // via Sign in with Apple into a session in your system
                                    //     // final signInWithAppleEndpoint = Uri(
                                    //     //   scheme: 'https',
                                    //     //   host:
                                    //     //       'flutter-sign-in-with-apple-example.glitch.me',
                                    //     //   path: '/sign_in_with_apple',
                                    //     //   queryParameters: <String, String>{
                                    //     //     'code':
                                    //     //         credential.authorizationCode,
                                    //     //     if (credential.givenName != null)
                                    //     //       'firstName':
                                    //     //           credential.givenName!,
                                    //     //     if (credential.familyName != null)
                                    //     //       'lastName':
                                    //     //           credential.familyName!,
                                    //     //     'useBundleId': !kIsWeb &&
                                    //     //             (Platform.isIOS ||
                                    //     //                 Platform.isMacOS)
                                    //     //         ? 'true'
                                    //     //         : 'false',
                                    //     //     if (credential.state != null)
                                    //     //       'state': credential.state!,
                                    //     //   },
                                    //     // );

                                    //     // final session =
                                    //     //     await http.Client().post(
                                    //     //   signInWithAppleEndpoint,
                                    //     // );

                                    //     // // If we got this far, a session based on the Apple ID credential has been created in your system,
                                    //     // // and you can now set this as the app's session
                                    //     // // ignore: avoid_print
                                    //     // print(session);
                                    //   },
                                    // ),
                                    child: AppleAuthButton(
                                      onPressed:
                                          _handleSignUp(_handleAppleSignIn),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
    );
  }

  void signUpFunction() {}
}
