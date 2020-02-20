import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/barks.dart';
import './bark_select_card.dart';

class SelectBarksList extends StatelessWidget {
  Widget build(BuildContext context) {
    final barks = Provider.of<Barks>(context);
    return Column(
      children: <Widget>[
        Center(
          child: Text(
            "Animal Sounds",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Divider(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: barks.all.length,
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              value: barks.all[i],
              child: BarkSelectCard(i, barks.all[i]),
            ),
          ),
        ),
      ],
    );
  }
}
