import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/screens/photo_library_screen.dart';
import 'package:K9_Karaoke/screens/set_picture_coordinates_screen.dart';
import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/the_user.dart';
import '../widgets/info_popup.dart';

// ignore: must_be_immutable
class CardTypeScreen extends StatelessWidget {
  static const routeName = 'card-type-screen';
  late KaraokeCard card;
  late CurrentActivity currentActivity;

  backCallback(context) {
    currentActivity.setCardCreationStep(CardCreationSteps.snap);
    if (card.picture!.isStock!)
      Navigator.of(context).pushReplacementNamed(PhotoLibraryScreen.routeName);
    else
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              SetPictureCoordinatesScreen(card.picture!, editing: true),
        ),
      );
    if (!card.picture!.isStock!) Navigator.of(context).pop();
  }

  bool _isPreview(BuildContext context) {
    TheUser? user;
    user ??= Provider.of<TheUser>(context, listen: false);
    return user!.email == InfoPopup.guest;
  }

  Widget build(BuildContext context) {
    print("Building CardTypeScreen");

    double textSize = 14;

    currentActivity = Provider.of<CurrentActivity>(context, listen: false);
    card = Provider.of<KaraokeCards>(context, listen: false).current!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(noName: true),
      body: Container(
        // appbar offset
        padding: EdgeInsets.only(top: 90),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/create_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Padding(
            //   padding: EdgeInsets.only(top: 0, bottom: 10),
            //   child: InterfaceTitleNav(
            //     title: "Choose Type Of\nGreeting Card",
            //     titleSize: 20,
            //     backCallback: () =>
            //         Navigator.of(context).popAndPushNamed(MenuScreen.routeName),
            //   ),
            // ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => backCallback(context),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(FontAwesomeIcons.angleLeft,
                        color: Theme.of(context).primaryColor),
                    Text(
                      'Back',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20, left: 40),
                      child: Text(
                        "Choose Type Of\nGreeting Card",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Stack(
              children: [
                Positioned(
                  right: 20,
                  top: 30,
                  child: Icon(Icons.mail_outline, size: 40, color: Colors.grey),
                ),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Now that you have your dog ready,\nselect what type of card you want.",
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 5, horizontal: 30.0),
              child: Divider(
                color: Colors.grey[300],
                thickness: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text("CARD WITH NEW SONG",
                              style: TextStyle(
                                  fontSize: textSize,
                                  color: Theme.of(context).primaryColor),
                              textAlign: TextAlign.center),
                        ),
                        RawMaterialButton(
                          constraints:
                              BoxConstraints(maxWidth: 150, maxHeight: 45),
                          onPressed: () {
                            currentActivity.setNewSong();
                            Navigator.of(context).pop();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 5.0, right: 8.0),
                                child: Icon(
                                  FontAwesomeIcons.music,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "GO",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: textSize,
                                ),
                              ),
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          elevation: 2.0,
                          fillColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                  ),
                  Container(
                    width: 200,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text("USE SONG \nALREADY MADE",
                              style: TextStyle(
                                  fontSize: textSize,
                                  color: Theme.of(context).primaryColor),
                              textAlign: TextAlign.center),
                        ),
                        RawMaterialButton(
                          constraints:
                              BoxConstraints(maxWidth: 150, maxHeight: 45),
                          onPressed: _isPreview(context)
                              ? () {InfoPopup.displayInfo(context, "Guests cannot access this function.", InfoPopup.signup);}
                              : () {
                            currentActivity.setOldSong();
                            Navigator.of(context).pop();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 5.0, right: 8.0),
                                child: Icon(
                                  FontAwesomeIcons.plus,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "GO",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: textSize,
                                ),
                              ),
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          elevation: 2.0,
                          fillColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                  ),
                  Container(
                    width: 200,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text("JUST VOICE MESSAGE\nNO SONG",
                              style: TextStyle(
                                  fontSize: textSize,
                                  color: Theme.of(context).primaryColor),
                              textAlign: TextAlign.center),
                        ),
                        RawMaterialButton(
                          constraints:
                              BoxConstraints(maxWidth: 150, maxHeight: 45),
                          onPressed: () {
                            currentActivity.setJustMessage();
                            currentActivity
                                .setCardCreationStep(CardCreationSteps.speak);
                            currentActivity.setCardCreationSubStep(
                                CardCreationSubSteps.seven);

                            Navigator.of(context).pop();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 5.0, right: 8.0),
                                child: Icon(
                                  FontAwesomeIcons.microphone,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "GO",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: textSize,
                                ),
                              ),
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          elevation: 2.0,
                          fillColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
