import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/bark_playback_card.dart';
import './bark_playback_card.dart';
import '../widgets/record_button.dart';
import '../providers/barks.dart';
import '../providers/sound_controller.dart';

class BarkList extends StatefulWidget {
  @override
  _BarkListState createState() => _BarkListState();
}

class _BarkListState extends State<BarkList> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final SoundController soundController =
        Provider.of<SoundController>(context);

    final barks = Provider.of<Barks>(context, listen: false);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RecordButton(),
        ),
        Expanded(
          child: AnimatedList(
            key: barks.listKey,
            initialItemCount: barks.all.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (ctx, i, Animation<double> animation) => BarkPlaybackCard(i, barks.all[i], barks, soundController, animation),
          ),
        ),
      ],
    );
  }
}
