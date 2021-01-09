import 'package:K9_Karaoke/animations/bounce.dart';
import 'package:K9_Karaoke/providers/barks.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/widgets/bark_playback_card.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sound_controller.dart';

class BarkSelectInterface extends StatefulWidget {
  @override
  _BarkSelectInterfaceState createState() => _BarkSelectInterfaceState();
}

enum BarkTypes {
  stock,
  fx,
  myBarks,
}

class _BarkSelectInterfaceState extends State<BarkSelectInterface>
    with SingleTickerProviderStateMixin {
  BarkTypes currentBarks = BarkTypes.myBarks;
  CurrentActivity currentActivity;
  Barks barks;
  List<Bark> displayedBarks;
  final _listKey = GlobalKey<AnimatedListState>();
  SoundController soundController;
  bool _isFirstLoad = true;

  var cards = KaraokeCards();

  String get _currentBarkLength {
    if (currentActivity.isTwo) {
      return "SHORT";
    } else if (currentActivity.isThree) {
      return "MEDIUM";
    } else if (currentActivity.isFour) {
      return "FINALE";
    }
  }

  getBarksOfCurrentLength({bool stock = false, bool fx = false}) {
    if (currentActivity.isTwo) {
      return barks.barksOfLength("short", stock: stock, fx: fx);
    } else if (currentActivity.isThree) {
      return barks.barksOfLength("medium", stock: stock, fx: fx);
    } else if (currentActivity.isFour) {
      return barks.barksOfLength("finale", stock: stock, fx: fx);
    }
  }

  updateDisplayedBarks({bool stock = false, bool fx = false}) {
    List newBarks = getBarksOfCurrentLength(stock: stock, fx: fx);
    if (newBarks == null) return;
    List toRemove = [];
    // remove barks
    displayedBarks.asMap().forEach((i, bark) {
      if (newBarks.indexOf(bark) == -1) toRemove.add(i);
    });
    // print("toRemove: $toRemove");
    // print("shownBarks before removal: $shownBarks");

    toRemove.reversed.forEach((i) {
      Bark removedBark = displayedBarks[i];
      displayedBarks.remove(removedBark);
      _listKey.currentState?.removeItem(
        i,
        (context, animation) =>
            BarkPlaybackCard(i, removedBark, barks, soundController, animation),
      );
    });

    newBarks.reversed.forEach((newBark) {
      if (displayedBarks.indexOf(newBark) == -1) {
        displayedBarks.insert(0, newBark);
        _listKey.currentState?.insertItem(0);
      }
    });
  }

  _updateDisplayBarks() {
    if (_isFirstLoad) {
      displayedBarks = getBarksOfCurrentLength();
      setState(() => _isFirstLoad = false);
    } else {
      updateDisplayedBarks(
          stock: currentBarks == BarkTypes.stock,
          fx: currentBarks == BarkTypes.fx);
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

  bool _noDisplayedBarks() {
    return currentBarks == BarkTypes.myBarks && displayedBarks.length == 0;
  }

  Widget _showBarks() {
    if (_noDisplayedBarks())
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 48.0),
          child: Text(
            "No ${_currentBarkLength.toLowerCase()} barks recorded.\nTry 'Stock Barks' or 'FX',\nor go back.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      );
    else
      return AnimatedList(
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
      );
  }

  bool get _canSkipShort {
    return currentActivity.isTwo && cards.current.shortBark != null;
  }

  bool get _canSkipMedium {
    return currentActivity.isThree && cards.current.mediumBark != null;
  }

  bool get _canSkipLong {
    return currentActivity.isFour && cards.current.longBark != null;
  }

  Function skipLogic() {
    if (_canSkipShort || _canSkipMedium || _canSkipLong)
      return currentActivity.setNextSubStep;
    else
      return null;
  }

  Widget build(BuildContext context) {
    barks = Provider.of<Barks>(context);
    soundController = Provider.of<SoundController>(context);
    currentActivity = Provider.of<CurrentActivity>(context);
    cards = Provider.of<KaraokeCards>(context);
    _updateDisplayBarks();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        InterfaceTitleNav(
          "PICK $_currentBarkLength BARK",
          skipCallback: skipLogic(),
          backCallback: currentActivity.setPreviousSubStep,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Spacer(),
            Expanded(
              flex: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RawMaterialButton(
                    // constraints:
                    //         const BoxConstraints(minWidth: 70, minHeight: 33),
                    onPressed: () =>
                        setState(() => currentBarks = BarkTypes.myBarks),
                    child: Text(
                      "My Barks",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: currentBarks == BarkTypes.myBarks
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                          fontSize: 15),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                      side: BorderSide(
                          color: Theme.of(context).primaryColor, width: 3),
                    ),
                    elevation: 2.0,
                    fillColor: currentBarks == BarkTypes.myBarks
                        ? Theme.of(context).primaryColor
                        : null,
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 18.0),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    overflow: Overflow.visible,
                    children: [
                      RawMaterialButton(
                        constraints:
                            const BoxConstraints(minWidth: 33, minHeight: 33),
                        onPressed: () {
                          setState(() => currentBarks = BarkTypes.stock);
                        },
                        child: Text(
                          "Stock Barks",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: currentBarks == BarkTypes.stock
                                ? Colors.white
                                : Theme.of(context).primaryColor,
                            fontSize: 15,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                          side: BorderSide(
                              color: Theme.of(context).primaryColor, width: 3),
                        ),
                        elevation: 2.0,
                        fillColor: currentBarks == BarkTypes.stock
                            ? Theme.of(context).primaryColor
                            : null,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 18),
                      ),
                      if (currentBarks == BarkTypes.myBarks &&
                          displayedBarks.length == 0)
                        Positioned(
                          right: 28,
                          child: Bounce(
                              icon: Icon(Icons.arrow_upward,
                                  size: 50,
                                  color: Theme.of(context).primaryColor),
                              begin: 35,
                              end: 50),
                        ),
                    ],
                  ),
                  Stack(
                    overflow: Overflow.visible,
                    children: [
                      RawMaterialButton(
                        constraints:
                            const BoxConstraints(minWidth: 25, minHeight: 25),
                        onPressed: () =>
                            setState(() => currentBarks = BarkTypes.fx),
                        child: Text(
                          "FX",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: currentBarks == BarkTypes.fx
                                ? Colors.white
                                : Theme.of(context).primaryColor,
                            fontSize: 15,
                          ),
                        ),
                        shape: CircleBorder(
                          side: BorderSide(
                              color: Theme.of(context).primaryColor, width: 3),
                        ),
                        elevation: 2.0,
                        fillColor: currentBarks == BarkTypes.fx
                            ? Theme.of(context).primaryColor
                            : null,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                      ),
                      if (currentBarks == BarkTypes.myBarks &&
                          displayedBarks.length == 0)
                        Bounce(
                            icon: Icon(Icons.arrow_upward,
                                size: 50,
                                color: Theme.of(context).primaryColor),
                            begin: 35,
                            end: 50),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(padding: EdgeInsets.only(top: 5)),
        SizedBox(
          height: MediaQuery.of(context).size.height / 2.2,
          child: _showBarks(),
        ),
      ],
    );
  }
}
