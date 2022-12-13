import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:K9_Karaoke/widgets/terms_of_use.dart';
import 'package:flutter/material.dart';

class UserAgreement extends StatelessWidget {
  final Function acceptCallback;

  UserAgreement(this.acceptCallback);

  void userAgrees() {
    acceptCallback(true);
  }

  void userDeclines() {
    acceptCallback(false);
  }

  @override
  Widget build(BuildContext context) {
    final title = TextStyle(
        fontWeight: FontWeight.w800, color: Colors.black, fontSize: 22);
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(isMenu: true, pageTitle: "Terms of Use"),
      // Background image
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/menu_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Padding(padding: EdgeInsets.only(top: 75)),
            TermsOfUse(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed:userDeclines,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).errorColor,
                        borderRadius: BorderRadius.all(Radius.circular(22.0)),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 6, horizontal: 20),
                      child: const Text("Decline",
                          style:TextStyle(color: Colors.white, fontSize: 20)
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed:userAgrees,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(22.0)),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 6, horizontal: 20),
                      child: const Text("Accept",
                          style:TextStyle(color: Colors.white, fontSize: 20)
                      ),
                    ),
                  ),
                  // FlatButton(
                  //   padding: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                  //   child: Text("Decline", style: TextStyle(fontSize: 20)),
                  //   color: Theme.of(context).errorColor,
                  //   onPressed: userDeclines,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(22.0),
                  //   ),
                  // ),
                  // FlatButton(
                  //   padding: EdgeInsets.symmetric(vertical: 6, horizontal: 22),
                  //   child: Text("Agree", style: TextStyle(fontSize: 20)),
                  //   color: Theme.of(context).primaryColor,
                  //   onPressed: userAgrees,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(22.0),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
