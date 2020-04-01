import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:song_barker/providers/spinner_state.dart';

import '../widgets/bark_playback_card.dart';
import './bark_playback_card.dart';
import '../widgets/record_button.dart';
import '../providers/barks.dart';
import '../providers/sound_controller.dart';

class BarkList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SoundController soundController =
        Provider.of<SoundController>(context);
    final barks = Provider.of<Barks>(context, listen: false);
    return Column(
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.all(8),
            child: Align(
              // alignment: Alignment(-.9, 0),
              child: RecordButton(),
            ),
          ),
       
        Consumer<SpinnerState>(builder: (ctx, spinState, _) {
          return Column(
            children: <Widget>[
              Visibility(
                visible: spinState.barksLoading,
                // visible: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SpinKitWave(
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
        Expanded(
          child: AnimatedList(
            key: barks.listKey,
            initialItemCount: barks.all.length,
            // padding: const EdgeInsets.all(0),
            itemBuilder: (ctx, i, Animation<double> animation) =>
                BarkPlaybackCard(
                    i, barks.all[i], barks, soundController, animation),
          ),
        ),
      ],
    );
  }
}
