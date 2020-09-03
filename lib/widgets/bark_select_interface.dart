import 'package:K9_Karaoke/providers/barks.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/widgets/bark_playback_card.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
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
  List<Bark> displayedBarks;
  List<Bark> displayedBarksStock;
  final _listKey = GlobalKey<AnimatedListState>();
  final _stockListKey = GlobalKey<AnimatedListState>();
  SoundController soundController;
  bool _isFirstLoad = true;

  String _barkSelectInstruction() {
    print(
        "activity within instructions call: ${currentActivity.cardCreationSubStep}");
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

  updateDisplayedBarks([bool isStock = false]) {
    List newBarks = getBarksOfCurrentLength(isStock);
    List shownBarks = isStock ? displayedBarksStock : displayedBarks;
    var listKey = isStock ? _stockListKey : _listKey;
    List toRemove = [];
    // remove barks
    shownBarks.asMap().forEach((i, bark) {
      if (newBarks.indexOf(bark) == -1) toRemove.add(i);
    });
    print("toRemove: $toRemove");
    print("shownBarks before removal: $shownBarks");

    toRemove.reversed.forEach((i) {
      shownBarks.removeAt(i);
      listKey.currentState?.removeItem(
          i,
          (context, animation) => BarkPlaybackCard(
              i, shownBarks[i], barks, soundController, animation));
    });
    // add barks
    print("newBarks: $newBarks");
    print("shownBarks $isStock: $shownBarks");

    newBarks.forEach((newBark) {
      if (shownBarks.indexOf(newBark) == -1) {
        print("checkpoint before: ${listKey}, ${listKey.currentState}");
        listKey.currentState?.insertItem(0);
        print("checkpoint after");
        shownBarks.insert(0, newBark);
      }
    });
    print("user's displayed barks: ${displayedBarks.map((el) => el.length)}");
  }

  _updateDisplayBarks() {
    if (_isFirstLoad) {
      displayedBarks = getBarksOfCurrentLength();
      displayedBarksStock = getBarksOfCurrentLength(true);
      setState(() => _isFirstLoad = false);
    } else {
      updateDisplayedBarks();
      updateDisplayedBarks(true);
    }
  }

  deleteBark(Bark bark, num displayInt) {
    displayedBarks.removeAt(displayInt);
    _listKey.currentState.removeItem(
      displayInt,
      (context, animation) => BarkPlaybackCard(
        displayInt,
        bark,
        barks,
        soundController,
        animation,
      ),
    );
    barks.remove(bark);
    print("${bark.name} deleted...");
  }

  _skipCallback() {
    return _canSkip() ? currentActivity.setNextSubStep : null;
  }

  Widget build(BuildContext context) {
    barks = Provider.of<Barks>(context);
    soundController = Provider.of<SoundController>(context);
    currentActivity = Provider.of<CurrentActivity>(context);
    print(
        "Bark select interface and Substep: ${currentActivity.cardCreationSubStep}");
    _updateDisplayBarks();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        interfaceTitleNav(context, "PICK " + _barkSelectInstruction(),
            skipCallback: _skipCallback(),
            backCallback: currentActivity.setPreviousSubStep),
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
                side:
                    BorderSide(color: Theme.of(context).primaryColor, width: 3),
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
                side:
                    BorderSide(color: Theme.of(context).primaryColor, width: 3),
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
        SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: viewingStockBarks
              ? AnimatedList(
                  key: _stockListKey,
                  initialItemCount: displayedBarksStock.length,
                  itemBuilder: (ctx, i, animation) => BarkPlaybackCard(
                    i,
                    displayedBarksStock[i],
                    barks,
                    soundController,
                    animation,
                  ),
                )
              : AnimatedList(
                  key: _listKey,
                  initialItemCount: displayedBarks.length,
                  itemBuilder: (ctx, i, animation) => BarkPlaybackCard(
                    i,
                    displayedBarks[i],
                    barks,
                    soundController,
                    animation,
                    deleteCallback: deleteBark,
                  ),
                ),
        ),
      ],
    );
  }
}
