import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/barks.dart';
import './bark_playback_button.dart';
import '../screens/pet_details_screen.dart';

class BarksGrid extends StatelessWidget {
  Widget build(BuildContext context) {
    final barks = Provider.of<Barks>(context);
    return Column(
      children: <Widget>[
                Center(child: Text("Animal Sounds", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),),

        Divider(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: barks.all.length,
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              value: barks.all[i],
              child: BarkPlaybackButton(i, barks.all[i]),
            ),
          ),
        ),
      ],
    );
  }
}
