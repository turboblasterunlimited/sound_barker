import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_barker/functions/app_storage_path.dart';

import '../providers/greeting_cards.dart';
import '../widgets/greeting_card_card.dart';

class GreetingCardGrid extends StatefulWidget {
  @override
  _GreetingCardGridState createState() => _GreetingCardGridState();
}

class _GreetingCardGridState extends State<GreetingCardGrid>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    GreetingCards cards = Provider.of<GreetingCards>(context);
    print(myAppStoragePath);
    return Column(
      children: <Widget>[
        ButtonBar(
          // buttonPadding: EdgeInsets.fromLTRB(5, 5, 5, 5),
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            RawMaterialButton(
              onPressed: () {
                // 1st CREATE CARD SCREEN
              },
              child: Text(
                "CREATE CARD",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.0),
                // side: BorderSide(color: Colors.red),
              ),
              elevation: 2.0,
              fillColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ],
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: cards.all.length,
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              value: cards.all[i],
              key: UniqueKey(),
              child: GreetingCardCard(i, cards.all[i], cards),
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              // childAspectRatio: 3 / 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
          ),
        ),
      ],
    );
  }
}
