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

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/backgrounds/menu_background.png"),
          fit: BoxFit.cover,
        ),
      ),
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Center(child: Text("User Agreement", style: title)),
          TermsOfUse(),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Text("Decline", style: TextStyle(fontSize: 20)),
                  color: Theme.of(context).errorColor,
                  onPressed: userDeclines,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Text("Agree", style: TextStyle(fontSize: 20)),
                  color: Theme.of(context).primaryColor,
                  onPressed: userAgrees,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
