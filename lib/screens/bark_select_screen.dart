import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:song_barker/providers/sound_controller.dart';
import 'package:song_barker/widgets/bark_select_card.dart';
import '../providers/barks.dart';
import '../widgets/bark_select_card.dart';

class BarkSelectScreen extends StatefulWidget {
  final song;
  BarkSelectScreen(this.song);

  @override
  _BarkSelectScreenState createState() => _BarkSelectScreenState();
}

class _BarkSelectScreenState extends State<BarkSelectScreen> {
  @override
  Widget build(BuildContext context) {
    Barks barks = Provider.of<Barks>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white, size: 30),
        backgroundColor: Theme.of(context).accentColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Pick a sound",
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
              itemBuilder: (ctx, i) => BarkSelectCard(
                barks.all[i],
                widget.song,
                Provider.of<SoundController>(context, listen: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
