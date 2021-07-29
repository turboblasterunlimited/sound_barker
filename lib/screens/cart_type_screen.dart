import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/screens/photo_library_screen.dart';
import 'package:K9_Karaoke/screens/set_picture_coordinates_screen.dart';
import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';

import 'menu_screen.dart';

class CardTypeScreen extends StatelessWidget {
  static const routeName = 'card-type-screen';
  KaraokeCard card;
  CurrentActivity currentActivity;

  backCallback(context) {
    currentActivity.setCardCreationStep(CardCreationSteps.snap);
    if (card.picture.isStock)
      Navigator.of(context).pushReplacementNamed(PhotoLibraryScreen.routeName);
    else
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              SetPictureCoordinatesScreen(card.picture, editing: true),
        ),
      );
    if (!card.picture.isStock) Navigator.of(context).pop();
  }

  Widget build(BuildContext context) {
    print("Building CardTypeScreen");

    double textSize = 14;

    currentActivity = Provider.of<CurrentActivity>(context, listen: false);
    card = Provider.of<KaraokeCards>(context, listen: false).current;

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(noName: true),
      body: Container(
        // appbar offset
        padding: EdgeInsets.only(top: 70),
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
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(LineAwesomeIcons.angle_left,
                        color: Theme.of(context).primaryColor),
                    Text(
                      'Back',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 40),
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
                                  LineAwesomeIcons.music,
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
                          onPressed: () {
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
                                  LineAwesomeIcons.plus,
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
                                  LineAwesomeIcons.microphone,
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
