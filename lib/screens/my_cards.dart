import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_card_decoration_controller.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/the_user.dart';
import 'package:K9_Karaoke/screens/photo_library_screen.dart';
import 'package:K9_Karaoke/widgets/card_card.dart';
import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';
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
  TheUser user;

  List<Widget> _cardGridTiles() {
    user.subscribed;
    List<Widget> widgets = [];
    widgets.add(_addCardButton());
    cards.all.asMap().forEach((index, card) {
      widgets.add(CardCard(card, cards, user.subscribed || index == 0));
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
    user = Provider.of<TheUser>(context);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);
    cardDecorator =
        Provider.of<KaraokeCardDecorationController>(context, listen: false);
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(noName: true),
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
              padding: EdgeInsets.only(top: 60, bottom: 10),
              child: InterfaceTitleNav(
                title: "YOUR CARDS",
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
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
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
