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
  List<Bark> displayedBarksStock;
  List<Bark> displayedFX;
  final _listKey = GlobalKey<AnimatedListState>();
  final _stockListKey = GlobalKey<AnimatedListState>();
  final _fxListKey = GlobalKey<AnimatedListState>();
  SoundController soundController;
  bool _isFirstLoad = true;
  AnimationController animationController;
  var tween;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      // lowerBound: -60,
      // upperBound: -40,
      duration: Duration(seconds: 1),
    )
      // ..addListener(() => setState(() {}))
      ..repeat(reverse: true);

    tween = Tween(begin: -60.0, end: -40.0).animate(animationController);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

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

  getBarksOfCurrentLength({bool stock = false, bool fx = false}) {
    if (currentActivity.isTwo) {
      return barks.barksOfLength("short", stock: stock, fx: fx);
    } else if (currentActivity.isThree) {
      return barks.barksOfLength("medium", stock: stock, fx: fx) +
          barks.barksOfLength("short", stock: stock, fx: fx);
    } else if (currentActivity.isFour) {
      return barks.barksOfLength("long", stock: stock, fx: fx) +
          barks.barksOfLength("medium", stock: stock, fx: fx) +
          barks.barksOfLength("short", stock: stock, fx: fx);
    }
  }

  updateDisplayedBarks({bool stock = false, bool fx = false}) {
    List newBarks = getBarksOfCurrentLength(stock: stock, fx: fx);

    List shownBarks;
    var listKey;
    if (currentBarks == BarkTypes.myBarks) {
      print("mybarks");
      shownBarks = displayedBarks;
      listKey = _listKey;
    } else if (currentBarks == BarkTypes.stock) {
      print("stock");
      shownBarks = displayedBarksStock;
      listKey = _stockListKey;
    } else if (currentBarks == BarkTypes.fx) {
      print("FX");
      shownBarks = displayedFX;
      listKey = _fxListKey;
    }
    List toRemove = [];
    // remove barks
    shownBarks.asMap().forEach((i, bark) {
      if (newBarks.indexOf(bark) == -1) toRemove.add(i);
    });
    // print("toRemove: $toRemove");
    // print("shownBarks before removal: $shownBarks");

    toRemove.reversed.forEach((i) {
      shownBarks.removeAt(i);
      listKey.currentState?.removeItem(
          i,
          (context, animation) => BarkPlaybackCard(
              i, shownBarks[i], barks, soundController, animation));
    });

    newBarks.forEach((newBark) {
      if (shownBarks.indexOf(newBark) == -1) {
        listKey.currentState?.insertItem(0);
        shownBarks.insert(0, newBark);
      }
    });
  }

  _updateDisplayBarks() {
    if (_isFirstLoad) {
      displayedBarks = getBarksOfCurrentLength();
      displayedBarksStock = getBarksOfCurrentLength(stock: true);
      displayedFX = getBarksOfCurrentLength(fx: true);
      setState(() => _isFirstLoad = false);
    } else {
      updateDisplayedBarks(
          stock: currentBarks == BarkTypes.stock,
          fx: currentBarks == BarkTypes.fx);
      // updateDisplayedBarks(stock: true);
      // updateDisplayedBarks(fx: true);
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

  _noRecordedShortBarks() {
    return currentActivity.isTwo && displayedBarks.length == 0;
  }

  Widget _showBarks() {
    if (currentBarks == BarkTypes.myBarks && _noRecordedShortBarks())
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Text(
            "No short barks recorded.\nTry 'Stock Barks' or 'FX',\nor go back.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      );
    else if (currentBarks == BarkTypes.myBarks)
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
    else if (currentBarks == BarkTypes.stock)
      return AnimatedList(
        key: _stockListKey,
        initialItemCount: displayedBarksStock.length,
        itemBuilder: (ctx, i, animation) => BarkPlaybackCard(
          i,
          displayedBarksStock[i],
          barks,
          soundController,
          animation,
        ),
      );
    else if (currentBarks == BarkTypes.fx)
      return AnimatedList(
        key: _fxListKey,
        initialItemCount: displayedFX.length,
        itemBuilder: (ctx, i, animation) => BarkPlaybackCard(
          i,
          displayedFX[i],
          barks,
          soundController,
          animation,
        ),
      );
  }

  Widget build(BuildContext context) {
    barks = Provider.of<Barks>(context);
    soundController = Provider.of<SoundController>(context);
    currentActivity = Provider.of<CurrentActivity>(context);
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
            Spacer(),
            RawMaterialButton(
              onPressed: () => setState(() => currentBarks = BarkTypes.myBarks),
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
                side:
                    BorderSide(color: Theme.of(context).primaryColor, width: 3),
              ),
              elevation: 2.0,
              fillColor: currentBarks == BarkTypes.myBarks
                  ? Theme.of(context).primaryColor
                  : null,
              padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 18.0),
            ),
            Padding(padding: EdgeInsets.all(10)),
            Stack(
              children: [
                RawMaterialButton(
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                ),
                if (barks.all.isEmpty)
                  AnimatedBuilder(
                      animation: animationController,
                      builder: (BuildContext context, Widget child) {
                        return Positioned(
                          bottom: tween.value,
                          left: 0,
                          right: 0,
                          child: Icon(Icons.arrow_upward,
                              size: 50, color: Theme.of(context).primaryColor),
                        );
                      }),
              ],
            ),
            RawMaterialButton(
              onPressed: () => setState(() => currentBarks = BarkTypes.fx),
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
                side:
                    BorderSide(color: Theme.of(context).primaryColor, width: 3),
              ),
              elevation: 2.0,
              fillColor: currentBarks == BarkTypes.fx
                  ? Theme.of(context).primaryColor
                  : null,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            ),
            Spacer(),
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
