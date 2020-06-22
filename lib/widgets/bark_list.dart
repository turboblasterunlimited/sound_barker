import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/bark_playback_card.dart';
import './bark_playback_card.dart';
import '../widgets/record_button.dart';
import '../providers/barks.dart';
import '../providers/sound_controller.dart';

class BarkList extends StatefulWidget {
  @override
  BarkListState createState() => BarkListState();
}

class BarkListState extends State<BarkList> {
  @override
  Widget build(BuildContext context) {
    final SoundController soundController =
        Provider.of<SoundController>(context);
    final barks = Provider.of<Barks>(context);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(0),
          child: Align(
            // alignment: Alignment(-.9, 0),
            child: RecordButton(),
          ),
        ),
        Visibility(
          visible: barks.all.isEmpty,
          child: Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                Icon(
                  Icons.arrow_upward,
                  size: 50,
                ),
                Text(
                  "Record your pet!",
                  style: TextStyle(fontSize: 25),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "K9 Karaoke will separate the sounds that it hears.", textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ])),
        ),
        Visibility(
          visible: barks.all.isNotEmpty,
          child: Expanded(
            child: AnimatedList(
              key: barks.listKey,
              initialItemCount: barks.all.length,
              // padding: const EdgeInsets.all(0),
              itemBuilder: (ctx, i, Animation<double> animation) =>
                  BarkPlaybackCard(
                      i, barks.all[i], barks, soundController, animation),
            ),
          ),
        ),
      ],
    );
  }
}
