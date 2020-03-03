import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sound/flutter_sound.dart';

import '../widgets/bark_playback_card.dart';
import './bark_playback_card.dart';
import '../widgets/record_button.dart';
import '../providers/barks.dart';
import '../providers/sound_controller.dart';

class BarkList extends StatefulWidget {
  @override
  _BarkListState createState() => _BarkListState();
}

class _BarkListState extends State<BarkList> {
  @override
  Widget build(BuildContext context) {
    FlutterSound flutterSound =
        Provider.of<SoundController>(context).flutterSound;

    final barks = Provider.of<Barks>(context);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RecordButton(),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: barks.all.length,
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              value: barks.all[i],
              child: BarkPlaybackCard(i, barks.all[i], flutterSound),
            ),
          ),
        ),
      ],
    );
  }
}
