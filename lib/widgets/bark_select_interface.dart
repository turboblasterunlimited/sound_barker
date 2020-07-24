import 'package:K9_Karaoke/providers/barks.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/screens/song_store_screen.dart';
import 'package:K9_Karaoke/widgets/bark_playback_card.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';

import '../providers/sound_controller.dart';

class BarkSelectInterface extends StatefulWidget {
  @override
  _BarkSelectInterfaceState createState() => _BarkSelectInterfaceState();
}

class _BarkSelectInterfaceState extends State<BarkSelectInterface> {
  bool viewingStockBarks = false;
  CurrentActivity currentActivity;

  String _barkSelectInstruction() {
    if (currentActivity.cardCreationSubStep == CardCreationSubSteps.two) {
      return "SHORT BARK";
    } else if (currentActivity.cardCreationSubStep ==
        CardCreationSubSteps.three) {
      return "MEDIUM BARK";
    } else if (currentActivity.cardCreationSubStep ==
        CardCreationSubSteps.four) {
      return "FINALE BARK";
    }
  }

  bool _canSkip() {
    // Can only Skip medium bark.
    return currentActivity.cardCreationSubStep == CardCreationSubSteps.three;
  }

  Widget build(BuildContext context) {
    final barks = Provider.of<Barks>(context);
    final soundController = Provider.of<SoundController>(context);
    currentActivity = Provider.of<CurrentActivity>(context);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        currentActivity.setPreviousSubStep();
                      },
                      child: Row(children: <Widget>[
                        Icon(LineAwesomeIcons.angle_left),
                        Text('Back'),
                      ]),
                    ),
                    Center(
                      child: Text(_barkSelectInstruction(),
                          style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).primaryColor)),
                    ),
                    if (_canSkip())
                      Positioned(
                        right: 10,
                        child: GestureDetector(
                          onTap: () {
                            currentActivity.setNextSubStep();
                          },
                          child: Row(
                            children: <Widget>[
                              Icon(LineAwesomeIcons.angle_right),
                              Text('Skip'),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RawMaterialButton(
                onPressed: () {},
                child: Text(
                  "My Barks",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                  side: BorderSide(
                      color: Theme.of(context).primaryColor, width: 3),
                ),
                elevation: 2.0,
                fillColor: Theme.of(context).primaryColor,
                padding:
                    const EdgeInsets.symmetric(vertical: 13, horizontal: 22.0),
              ),
              Padding(padding: EdgeInsets.all(10)),
              RawMaterialButton(
                onPressed: () =>
                    Navigator.pushNamed(context, SongStoreScreen.routeName),
                child: Text(
                  "Stock Barks",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                  side: BorderSide(
                      color: Theme.of(context).primaryColor, width: 3),
                ),
                elevation: 2.0,
                padding:
                    const EdgeInsets.symmetric(vertical: 13, horizontal: 22.0),
              ),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
          Visibility(
            visible: !viewingStockBarks,
            child: Expanded(
              child: AnimatedList(
                key: barks.listKey,
                initialItemCount: barks.all.length,
                itemBuilder: (ctx, i, Animation<double> animation) =>
                    BarkPlaybackCard(
                        i, barks.all[i], barks, soundController, animation),
              ),
            ),
          ),
          Visibility(
            visible: viewingStockBarks,
            child: Expanded(
              child: Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: barks.stockBarks.length,
                  itemBuilder: (ctx, i) =>
                      BarkPlaybackCard(i, barks.all[i], barks, soundController),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
