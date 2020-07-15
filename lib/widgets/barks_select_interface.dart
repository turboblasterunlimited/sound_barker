import 'package:K9_Karaoke/providers/barks.dart';
import 'package:K9_Karaoke/screens/song_store_screen.dart';
import 'package:K9_Karaoke/widgets/bark_playback_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sound_controller.dart';
import 'package:K9_Karaoke/widgets/song_playback_card.dart';
import '../providers/spinner_state.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class BarkSelectInterface extends StatefulWidget {
  @override
  _BarkSelectInterfaceState createState() => _BarkSelectInterfaceState();
}

class _BarkSelectInterfaceState extends State<BarkSelectInterface> {
  bool viewingStockBarks = false;

  Widget build(BuildContext context) {
    final barks = Provider.of<Barks>(context);
    final soundController = Provider.of<SoundController>(context);
    final spinnerState = Provider.of<SpinnerState>(context, listen: true);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
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
                onPressed: spinnerState.songLoading
                    ? null
                    : () {
                        Navigator.pushNamed(context, SongStoreScreen.routeName);
                      },
                child: spinnerState.songLoading
                    ? SpinKitWave(
                        color: Colors.white,
                        size: 20,
                      )
                    : Text(
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
            visible: !viewingStockBarks,
            child: Expanded(child: Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: stockBarks.length,
                itemBuilder: (ctx, i) => CreatableSongCard(
                    creatableSongs[i], soundController, cards, currentActivity),
              ),
            ),),
          ),
        ],
      ),
    );
  }
}
