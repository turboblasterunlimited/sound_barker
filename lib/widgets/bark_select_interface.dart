import 'package:K9_Karaoke/providers/barks.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
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
  Barks barks;

  String _barkSelectInstruction() {
    print("activity within instructions call: ${currentActivity.cardCreationSubStep}");
    if (currentActivity.isTwo) {
      return "SHORT BARK";
    } else if (currentActivity.isThree) {
      return "MEDIUM BARK";
    } else if (currentActivity.isFour) {
      return "FINALE BARK";
    }
  }

  bool _canSkip() {
    // Can only Skip medium bark.
    return currentActivity.cardCreationSubStep == CardCreationSubSteps.three;
  }

  getBarksOfCurrentLength([bool isStock = false]) {
    if (currentActivity.isTwo) {
      return barks.short(isStock);
    } else if (currentActivity.isThree) {
      return barks.medium(isStock) + barks.short(isStock);
    } else if (currentActivity.isFour) {
      return barks.long(isStock) + barks.medium(isStock) + barks.short(isStock);
    }
  }

  Widget build(BuildContext context) {
  
    barks = Provider.of<Barks>(context);
    final soundController = Provider.of<SoundController>(context);
    currentActivity = Provider.of<CurrentActivity>(context);
    print("activity substep: ${currentActivity.cardCreationSubStep}");
    // List<Bark> barksOfCurrentLength = getBarksOfCurrentLength();
    // List<Bark> barksOfCurrentLengthStock = getBarksOfCurrentLength(true);

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
                onPressed: () {
                  setState(() => viewingStockBarks = false);
                },
                child: Text(
                  "My Barks",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: viewingStockBarks
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                      fontSize: 16),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                  side: BorderSide(
                      color: Theme.of(context).primaryColor, width: 3),
                ),
                elevation: 2.0,
                fillColor:
                    viewingStockBarks ? null : Theme.of(context).primaryColor,
                padding:
                    const EdgeInsets.symmetric(vertical: 13, horizontal: 22.0),
              ),
              Padding(padding: EdgeInsets.all(10)),
              RawMaterialButton(
                onPressed: () {
                  setState(() => viewingStockBarks = true);
                },
                child: Text(
                  "Stock Barks",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: viewingStockBarks
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                  side: BorderSide(
                      color: Theme.of(context).primaryColor, width: 3),
                ),
                elevation: 2.0,
                fillColor:
                    viewingStockBarks ? Theme.of(context).primaryColor : null,
                padding:
                    const EdgeInsets.symmetric(vertical: 13, horizontal: 22.0),
              ),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
          if (!viewingStockBarks)
            Expanded(
              child: AnimatedList(
                key: barks.listKey,
                initialItemCount: getBarksOfCurrentLength().length,
                itemBuilder: (ctx, i, Animation<double> animation) =>
                    BarkPlaybackCard(
                  i,
                  getBarksOfCurrentLength()[i],
                  barks,
                  soundController,
                  animation,
                ),
              ),
            ),
          if (viewingStockBarks)
            Expanded(
              child: AnimatedList(
                key: barks.listKeyStock,
                initialItemCount: getBarksOfCurrentLength(true).length,
                itemBuilder: (ctx, i, Animation<double> animation) =>
                    BarkPlaybackCard(
                  i,
                  getBarksOfCurrentLength(true)[i],
                  barks,
                  soundController,
                  animation,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
