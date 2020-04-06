import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:song_barker/providers/sound_controller.dart';
import 'package:song_barker/widgets/bark_select_card.dart';
import '../providers/barks.dart';
import '../widgets/bark_select_card.dart';

class BarkSelectScreen extends StatefulWidget {
  final song;
  final List selectedBarkIds;
  BarkSelectScreen(this.song, {this.selectedBarkIds});

  @override
  _BarkSelectScreenState createState() => _BarkSelectScreenState();
}

class _BarkSelectScreenState extends State<BarkSelectScreen> {
  @override
  Widget build(BuildContext context) {
    final barks = Provider.of<Barks>(context, listen: false);
    final soundController = Provider.of<SoundController>(context, listen: false);
    String instructionText;

    if (widget.song["track_count"] == 1) {
      instructionText = "Pick a sound";
    } else if (widget.selectedBarkIds.length == 0) {
      instructionText = "Pick 1st sound";
    } else if (widget.selectedBarkIds.length == 1) {
      instructionText = "Pick 2nd sound";
    } else if (widget.selectedBarkIds.length == 2) {
      instructionText = "Pick 3rd sound";
    } else if (widget.selectedBarkIds.length == 3) {
      instructionText = "Pick 4th sound";
    } else if (widget.selectedBarkIds.length == 4) {
      instructionText = "Pick 5th sound";
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white, size: 30),
        backgroundColor: Theme.of(context).accentColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          instructionText,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 23, color: Colors.white),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: barks.all.length,
              itemBuilder: (ctx, i) => BarkSelectCard(barks.all[i], widget.song,
                  soundController, widget.selectedBarkIds),
            ),
          ),
        ],
      ),
    );
  }
}
