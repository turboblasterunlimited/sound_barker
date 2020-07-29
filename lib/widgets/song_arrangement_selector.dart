import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SongArrangementSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cards = Provider.of<KaraokeCards>(context, listen: false);
    final currentActivity =
        Provider.of<CurrentActivity>(context, listen: false);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(children: <Widget>[
          
        ],),
    ]);
  }
}
