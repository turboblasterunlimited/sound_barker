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
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white, size: 30),
        backgroundColor: Theme.of(context).accentColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Pick a Song",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 23, color: Colors.white),
        ),
      ),
      body: Column(
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
                  child: Text('Song Store',
                      style: TextStyle(fontSize: 20, color: Colors.grey[600])),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: creatableSongs.length,
              itemBuilder: (ctx, i) =>
                  CreatableSongCard(creatableSongs[i], soundController),
            ),
          ),
        ],
      ),
    );
  }
}
