import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_card_decoration_controller.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/screens/photo_library_screen.dart';
import 'package:K9_Karaoke/widgets/card_card.dart';
import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'package:K9_Karaoke/screens/menu_screen.dart';

class MyCardsScreen extends StatefulWidget {
  static const routeName = 'my-cards-screen';

  @override
  _MyCardsScreenState createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen> {
  KaraokeCards cards;
  CurrentActivity currentActivity;
  KaraokeCardDecorationController cardDecorator;

  List<Widget> _cardGridTiles() {
    List<Widget> widgets = [];
    widgets.add(_addCardButton());
    cards.all.forEach((card) {
      widgets.add(CardCard(card, cards));
    });
    return widgets;
  }

  Widget _addCardButton() {
    return GestureDetector(
      onTap: () {
        cards.newCurrent();
        cardDecorator.reset();
        currentActivity.setCardCreationStep(CardCreationSteps.snap);
        Navigator.popAndPushNamed(context, PhotoLibraryScreen.routeName);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(Icons.add,
                color: Theme.of(context).primaryColor, size: 50),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    cards = Provider.of<KaraokeCards>(context);
    print("card count ${cards.all.length}");
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);
    cardDecorator =
        Provider.of<KaraokeCardDecorationController>(context, listen: false);
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomPadding: false,
      appBar: customAppBar(context, noName: true),
      body: Container(
        // appbar offset
        padding: EdgeInsets.only(top: 80),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/create_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 10),
              child: InterfaceTitleNav(
                "KARAOKE CARDS",
                titleSize: 22,
                backCallback: () =>
                    Navigator.of(context).popAndPushNamed(MenuScreen.routeName),
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverGrid.count(
                    children: _cardGridTiles(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
