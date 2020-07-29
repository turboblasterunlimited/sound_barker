import 'package:K9_Karaoke/providers/creatable_songs.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/widgets/creatable_song_card.dart';
import '../providers/sound_controller.dart';

class CreatableSongSelectScreen extends StatefulWidget {
  static const routeName = 'song-store-screen';
  CreatableSongSelectScreen();

  @override
  _CreatableSongSelectScreenState createState() => _CreatableSongSelectScreenState();
}

class _CreatableSongSelectScreenState extends State<CreatableSongSelectScreen> {
  SoundController soundController;
  CreatableSongs creatableSongs;
  KaraokeCards cards;
  CurrentActivity currentActivity;


  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  Widget build(BuildContext context) {
    soundController = Provider.of<SoundController>(context);
    cards = Provider.of<KaraokeCards>(context, listen: false);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);
    creatableSongs = Provider.of<CreatableSongs>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomPadding: false,
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
            // top padding
            Padding(
              padding: EdgeInsets.only(top: 100),
            ),
            // title
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Stack(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Row(children: <Widget>[
                      Icon(LineAwesomeIcons.angle_left, color: Colors.grey),
                      Text(
                        'Back',
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                    ]),
                  ),
                  Center(
                    child: Text(
                      'Pick Song',
                      style: TextStyle(
                          fontSize: 20, color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: creatableSongs.all.length,
                itemBuilder: (ctx, i) => CreatableSongCard(
                    creatableSongs.all[i], soundController, cards, currentActivity),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
