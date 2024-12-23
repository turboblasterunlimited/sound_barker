import 'package:K9_Karaoke/animations/bounce.dart';
import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/barks.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/widgets/bark_playback_card.dart';
import 'package:K9_Karaoke/widgets/custom_dialog.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/flutter_sound_controller.dart';
import '../providers/the_user.dart';
import 'info_popup.dart';

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
  late CurrentActivity currentActivity;
  late Barks barks;
  List<Bark>? displayedBarks;
  final _listKey = GlobalKey<AnimatedListState>();
  late FlutterSoundController soundController;
  bool _isFirstLoad = true;
  KaraokeCards? cards;

  bool _useShorterBarks = false;

  TheUser? user;

  String get _currentBarkLength {
    if (currentActivity.isTwo) {
      return "SHORT";
    } else if (currentActivity.isThree) {
      return "MEDIUM";
    } else if (currentActivity.isFour) {
      return "FINALE";
    } else {
      print("Null bark length, should never get here.");
      return "";
    }
  }

  Color get _currentBarkColor {
    if (currentActivity.isTwo) {
      return Colors.orange[800]!;
    } else if (currentActivity.isThree) {
      return Colors.pink;
    } else if (currentActivity.isFour) {
      return Colors.green;
    } else {
      print("Null color, should never get here.");
      return Colors.black;
    }
  }

  getBarksOfCurrentLength({bool stock = false, bool fx = false}) {
    if (currentActivity.isTwo) {
      return barks.barksOfLength("short", stock: stock, fx: fx);
    } else if (currentActivity.isThree) {
      var barklist = barks.barksOfLength("medium", stock: stock, fx: fx);
      if (_useShorterBarks) {
        barklist =
            barklist + barks.barksOfLength("short", stock: stock, fx: fx);
      }
      //return barks.barksOfLength("medium", stock: stock, fx: fx);
      return barklist;
    } else if (currentActivity.isFour) {
      var barklist = barks.barksOfLength("finale", stock: stock, fx: fx);
      if (_useShorterBarks) {
        barklist = barklist +
            barks.barksOfLength("short", stock: stock, fx: fx) +
            barks.barksOfLength("medium", stock: stock, fx: fx);
      }
      return barklist;
      // return barks.barksOfLength("finale", stock: stock, fx: fx);
    }
  }

  updateDisplayedBarks({bool stock = false, bool fx = false}) {
    List? newBarks = getBarksOfCurrentLength(stock: stock, fx: fx);
    if (newBarks == null) return;

    List toRemove = [];
    // remove barks
    displayedBarks!.asMap().forEach((i, bark) {
      if (newBarks?.indexOf(bark) == -1) toRemove.add(i);
    });

    toRemove.reversed.forEach((i) {
      Bark removedBark = displayedBarks![i];
      displayedBarks!.remove(removedBark);
      _listKey.currentState?.removeItem(
        i,
        (context, animation) =>
            BarkPlaybackCard(i, removedBark, barks, soundController, animation),
      );
    });

    newBarks.reversed.forEach((newBark) {
      if (displayedBarks!.indexOf(newBark) == -1) {
        displayedBarks!.insert(0, newBark);
        _listKey.currentState?.insertItem(0);
      }
    });
  }

  _updateDisplayBarks() {
    if (_isFirstLoad) {
      setState(() => _useShorterBarks = false);
      displayedBarks = getBarksOfCurrentLength();
      setState(() => _isFirstLoad = false);
    } else {
      updateDisplayedBarks(
          stock: currentBarks == BarkTypes.stock,
          fx: currentBarks == BarkTypes.fx);
    }
  }

  deleteBark(Bark bark, int displayInt) {
    displayedBarks!.removeAt(displayInt);
    _listKey.currentState!.removeItem(
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
    return currentBarks == BarkTypes.myBarks && displayedBarks!.length == 0;
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
        initialItemCount: displayedBarks!.length,
        itemBuilder: (ctx, i, animation) => BarkPlaybackCard(
          i,
          displayedBarks![i],
          barks,
          soundController,
          animation,
          deleteCallback: deleteBark,
          color: _currentBarkColor,
        ),
      );
  }

  bool get _canSkipShort {
    return currentActivity.isTwo && cards!.current!.shortBark != null;
  }

  bool get _canSkipMedium {
    return currentActivity.isThree && cards!.current!.mediumBark != null;
  }

  bool get _canSkipLong {
    return currentActivity.isFour && cards!.current!.longBark != null;
  }

  Function? skipLogic() {
    if (_canSkipShort || _canSkipMedium || _canSkipLong) {
      setState(() => _useShorterBarks = false);
      return currentActivity.setNextSubStep;
    } else
      return null;
  }

  barkLengthInfoDialog(context) {
    return showDialog(
        context: context,
        builder: (BuildContext ctx) {
          print("INSIDE.");
          return CustomDialog(
            header: "Pick barks for ${cards!.current!.songFormula!.name}",
            bodyText: "This first SHORT bark should be one clear sound!",
            primaryFunction: (BuildContext modalContext) {
              Navigator.of(modalContext).pop();
            },
            iconPrimary: Icon(
              FontAwesomeIcons.music,
              size: 42,
              color: Colors.grey[300],
            ),
            iconSecondary: Icon(
              CustomIcons.modal_paws_topleft,
              size: 42,
              color: Colors.grey[300],
            ),
            oneButton: true,
            primaryButtonText: "Got It!",
          );
        });
  }

  Widget titleWidget() {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: "SELECT ",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Theme.of(context).primaryColor),
        ),
        TextSpan(
          text: _currentBarkLength,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: _currentBarkColor),
        ),
        TextSpan(
          text: " BARK",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Theme.of(context).primaryColor),
        ),
      ]),
    );
  }

  void handle_my_barks(BuildContext ctx) {
    if(user!.email == InfoPopup.guest) {
      InfoPopup.displayInfo(ctx, "My Barks functionality not available to guests.",
                InfoPopup.signup);
    }
    else {
      setState(() => currentBarks = BarkTypes.myBarks);
    }
  }

  @override
  Widget build(BuildContext context) {
    barks = Provider.of<Barks>(context);
    soundController = Provider.of<FlutterSoundController>(context);
    currentActivity = Provider.of<CurrentActivity>(context);
    cards = Provider.of<KaraokeCards>(context);
    _updateDisplayBarks();

    user ??= Provider.of<TheUser>(context, listen: false);

    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Theme.of(context).primaryColor;
      }
      return Theme.of(context).primaryColor;
    }

    // Show Bark Length Info Modal
    if (!cards!.current!.seenBarkLengthInfo) {
      cards!.current!.setSeenBarkLengthInfo(true);
      Future.delayed(Duration.zero, () => barkLengthInfoDialog(context));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        InterfaceTitleNav(
          titleWidget: titleWidget(),
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
                    onPressed: () => handle_my_barks(context),
//                        setState(() => currentBarks = BarkTypes.myBarks),
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
                    clipBehavior: Clip.none,
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
                          displayedBarks!.length == 0)
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
                    clipBehavior: Clip.none,
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
                          displayedBarks!.length == 0)
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
        /**
         * JMF 3/29/2021: Commented out replaced by following code
         */
        // Padding(padding: EdgeInsets.only(top: 5)),
        /*Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 1.0),
            child: Text(
              "SELECT",
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        )*/
        /**
         * JMF 3/29/2021: Added header row
         */
        Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          // Align(
          //   alignment: Alignment.centerLeft,
          //   child: Padding(
          //     padding: const EdgeInsets.only(left: 1.0),
          //     child: Text(
          //       "SELECT",
          //       style: TextStyle(
          //         color: Colors.blue,
          //         // decoration: TextDecoration.underline,
          //       ),
          //       textAlign: TextAlign.left,
          //     ),
          //   ),
          // ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                child: (currentActivity.isTwo || currentBarks == BarkTypes.fx)
                    ? Text(" ")
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: CheckboxListTile(
                          title: Transform.translate(
                            offset: const Offset(-20, 0),
                            child: Text("Include shorter barks"),
                          ),

                          value:
                              currentActivity.isTwo ? false : _useShorterBarks,
                          onChanged: (bool? value) {
                            var s = currentActivity.isTwo ? false : value!;
                            setState(() {
                              _useShorterBarks = s;
                            });
                          },
                          controlAffinity: ListTileControlAffinity
                              .leading, //  <-- leading Checkbox
                        ),
                      ),
              ),
              // Flexible(
              //   flex: 1,
              //   child: Align(
              //     alignment: Alignment.centerLeft,
              //     child: Checkbox(
              //         checkColor: Colors.white,
              //         //activeColor: Theme.of(context).primaryColor,
              //         fillColor: MaterialStateProperty.resolveWith(getColor),
              //         value: currentActivity.isTwo ? false : _useShorterBarks,
              //         onChanged: (bool? value) {
              //           var s = currentActivity.isTwo ? false : value!;
              //           setState(() {
              //             _useShorterBarks = s;
              //           });
              //         }),
              //   ),
              // ),
              // Flexible(
              //     flex: 1,
              //     fit: FlexFit.loose,
              //     child: Align(
              //         alignment: Alignment.centerLeft,
              //         child: Text(
              //           "USE SHORT BARKS",
              //           style: TextStyle(
              //             color: Theme.of(context).primaryColor,
              //             // decoration: TextDecoration.underline,
              //           ),
              //           textAlign: TextAlign.left,
              //         ))),
            ],
          ),
          Flexible(
              flex: 1,
              child: Align(
                  alignment: Alignment.center,
                  child: _noDisplayedBarks() ?
                    Text("",
                      style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      // decoration: TextDecoration.underline,
                      fontSize: 20,
                      ),
                      textAlign: TextAlign.center,)

                    : Text(
                                "Listen to " +
                                    _currentBarkLength +
                                    (currentBarks != BarkTypes.fx ? " barks" : " fx"),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  // decoration: TextDecoration.underline,
                                  fontSize: 20,
                                ),
                                textAlign: TextAlign.center,
                              ))),
        ]),
        SizedBox(
          height: MediaQuery.of(context).size.height / 2.2,
          child: _showBarks(),
        ),
      ],
    );
  }
}
