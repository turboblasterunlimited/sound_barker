// import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'dart:io';

import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/screens/share_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnvelopeScreen extends StatelessWidget {
  static const routeName = 'envelope-screen';

  void navigateToShare(BuildContext context, bool withEnvelope) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShareScreen(withEnvelope: withEnvelope),
      ),
    );
  }

  Widget _positionedImage(image, card) {
    return Positioned.fill(child: LayoutBuilder(
      builder: (_, constraints) {
        return Padding(
            padding: EdgeInsets.only(
              top: constraints.biggest.height * 72 / 778,
              bottom: constraints.biggest.height * 194 / 778,
            ),
            child: image);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    var card = Provider.of<KaraokeCards>(context, listen: false).current;

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      // appBar: CustomAppBar(isMenu: true, pageTitle: "Support"),
      // Background image
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/menu_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
            ),
            Stack(
              children: [
                Positioned(
                  right: 20,
                  bottom: 5,
                  child: Icon(
                    Icons.mail_outline_outlined,
                    size: 60,
                    color: Colors.grey[300],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text(
                      "Put your card in an envelope?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Divider(
                color: Colors.grey[300],
                thickness: 2,
              ),
            ),
            // ENVELOPE WITH CARD IMAGE
            Container(
              width: 300,
              padding: EdgeInsets.all(20),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Column(
                    children: [
                      Image.asset("assets/images/envelope_topflap.png"),
                      Image.asset("assets/images/envelope_inside.png"),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: SizedBox(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _positionedImage(
                            Image.file(
                              File(card!.picture!.filePath!),
                            ),
                            card,
                          ),
                          card.decorationImage != null
                              ? Image.file(
                                  File(card.decorationImage!.filePath!),
                                )
                              : Container(height: 200, width: 200)
                        ],
                      ),
                    ),
                  ),
                  Image.asset("assets/images/envelope_front.png"),
                ],
              ),
            ),
            // BUTTONS

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RawMaterialButton(
                  onPressed: () => navigateToShare(context, false),
                  child: Text(
                    "No",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 2.0,
                  fillColor: Theme.of(context).errorColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40.0, vertical: 2),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                ),
                RawMaterialButton(
                  onPressed: () => navigateToShare(context, true),
                  child: Text(
                    "Yes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 2.0,
                  fillColor: Theme.of(context).primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40.0, vertical: 2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
