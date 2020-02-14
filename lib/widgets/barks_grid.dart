import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';
import './bark_playback_button.dart';
import '../screens/pet_details_screen.dart';

class BarksGrid extends StatelessWidget {
  Widget build(BuildContext context) {
    final barks = Provider.of<User>(context).allBarks();
    return GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: barks.length,
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              value: barks[i],
              child: BarkPlaybackButton(),
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
          );
  }
}
