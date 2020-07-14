import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/songs.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/widgets/creatable_song_card.dart';
import '../providers/sound_controller.dart';

class SongStoreScreen extends StatefulWidget {
  static const routeName = 'song-store-screen';

  SongStoreScreen();

  @override
  _SongStoreScreenState createState() => _SongStoreScreenState();
}

class _SongStoreScreenState extends State<SongStoreScreen> {
  SoundController soundController;
  List creatableSongs;
  KaraokeCards cards;
  CurrentActivity currentActivity;

  List collectCreatableSongs() {
    print("result1: $creatableSongs");
    if (creatableSongs != null) return creatableSongs;
    creatableSongs = Provider.of<Songs>(context, listen: false).creatableSongs;
    creatableSongs.forEach((cs) {
      cs["backing_track_bucket_fp"] =
          "backing_tracks/${cs["backing_track"]}/0.aac";
    });
    creatableSongs.sort((a, b) => a['song_family'].compareTo(b['song_family']));
    print("result: $creatableSongs");
    return creatableSongs;
  }

  @override
  Widget build(BuildContext context) {
    creatableSongs = collectCreatableSongs();
    soundController = Provider.of<SoundController>(context);
    cards = Provider.of<KaraokeCards>(context, listen: false);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false, // Don't show the leading button
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset("assets/logos/K9_logotype.png", width: 80),
              Expanded(
                child: Center(),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/create_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            // title
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Stack(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Row(children: <Widget>[
                      Icon(LineAwesomeIcons.angle_left),
                      Text('Back'),
                    ]),
                  ),
                  Center(
                    child: Text(
                      'Song Library',
                      style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: creatableSongs.length,
                itemBuilder: (ctx, i) =>
                    CreatableSongCard(creatableSongs[i], soundController, cards, currentActivity),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
