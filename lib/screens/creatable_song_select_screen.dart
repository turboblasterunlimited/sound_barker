import 'package:K9_Karaoke/providers/songs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../services/rest_api.dart';
import 'package:K9_Karaoke/widgets/creatable_song_card.dart';
import '../providers/sound_controller.dart';

class CreatableSongSelectScreen extends StatefulWidget {
  static const routeName = 'creatable-song-select-screen';

  CreatableSongSelectScreen();

  @override
  _CreatableSongSelectScreenState createState() =>
      _CreatableSongSelectScreenState();
}

class _CreatableSongSelectScreenState extends State<CreatableSongSelectScreen> {
  SoundController soundController;
  List creatableSongs = [];

  Future<List> collectCreatableSongs() async {
    if (creatableSongs.length != 0) return creatableSongs;
    print("building creatable songs");
    creatableSongs = Provider.of<Songs>(context, listen: false).creatableSongs;
    print("creatable songs retrieved: $creatableSongs");
    creatableSongs.forEach((cs) {
      cs["backing_track_bucket_fp"] = "backing_tracks/${cs["backing_track"]}/0.aac";
    });
    return creatableSongs;
  }

  @override
  Widget build(BuildContext context) {
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
          Expanded(
            child: FutureBuilder(
                future: collectCreatableSongs(),
                builder: (context, projectSnap) {
                  if (projectSnap.connectionState == ConnectionState.waiting &&
                      projectSnap.hasData == false) {
                    print('project snapshot data is: ${projectSnap.data}');
                    return Center(
                        child: SpinKitWave(
                      color: Theme.of(context).primaryColor,
                      size: 80,
                    ));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: projectSnap.data.length,
                    itemBuilder: (ctx, i) => CreatableSongCard(
                        projectSnap.data.toList()[i], soundController),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
