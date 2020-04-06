import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_barker/functions/app_storage_path.dart';
import 'package:flutter/rendering.dart';

import 'package:song_barker/providers/active_wave_streamer.dart';
import './screens/song_category_select_screen.dart';
import './screens/main_screen.dart';
import './screens/select_song_and_picture_screen.dart';

import './providers/pictures.dart';
import './providers/barks.dart';
import './providers/songs.dart';
import './providers/image_controller.dart';
import './providers/sound_controller.dart';
import './providers/spinner_state.dart';
import './providers/greeting_cards.dart';



void main() async {
  // debugPaintSizeEnabled = true;

  runApp(MyApp());
  appStoragePath();

}

class MyApp extends StatelessWidget {
  Map<int, Color> color = {
    50: Color.fromRGBO(136, 14, 79, .1),
    100: Color.fromRGBO(136, 14, 79, .2),
    200: Color.fromRGBO(136, 14, 79, .3),
    300: Color.fromRGBO(136, 14, 79, .4),
    400: Color.fromRGBO(136, 14, 79, .5),
    500: Color.fromRGBO(136, 14, 79, .6),
    600: Color.fromRGBO(136, 14, 79, .7),
    700: Color.fromRGBO(136, 14, 79, .8),
    800: Color.fromRGBO(136, 14, 79, .9),
    900: Color.fromRGBO(136, 14, 79, 1),
  };

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Barks(),
        ),
        ChangeNotifierProvider.value(
          value: Songs(),
        ),
        ChangeNotifierProvider.value(
          value: ImageController(),
        ),
        ChangeNotifierProvider.value(
          value: Pictures(),
        ),
        ChangeNotifierProvider.value(
          value: GreetingCards(),
        ),
        ChangeNotifierProvider.value(
          value: SoundController(),
        ),
        ChangeNotifierProvider.value(
          value: ActiveWaveStreamer(),
        ),
        ChangeNotifierProvider.value(
          value: SpinnerState(),
        ),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Song Barker',
          theme: ThemeData(
            primarySwatch: MaterialColor(0xff419D78, color),
            accentColor: Color(0xff2D3047),
            fontFamily: 'Lato',
            buttonTheme: ButtonThemeData(
              minWidth: 200.0,
              height: 50.0,
              textTheme: ButtonTextTheme.primary,
              buttonColor: Colors.amber[200],
            ),
          ),
          home: MainScreen(),
          routes: {
            MainScreen.routeName: (ctx) => MainScreen(),
            SongCategorySelectScreen.routeName: (ctx) =>
                SongCategorySelectScreen(),
                SelectSongAndPictureScreen.routeName: (ctx) =>
                SelectSongAndPictureScreen(),
          }),
    );
  }
}
