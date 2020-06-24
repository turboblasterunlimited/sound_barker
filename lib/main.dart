import 'package:K9_Karaoke/providers/user.dart';
import 'package:K9_Karaoke/screens/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/providers/karaoke_card_decorator.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:flutter/rendering.dart';

import 'package:K9_Karaoke/providers/active_wave_streamer.dart';
import 'package:K9_Karaoke/services/http_controller.dart';
import './screens/main_screen.dart';
import './screens/select_song_and_picture_screen.dart';
import './screens/authentication_screen.dart';
import './screens/creatable_song_select_screen.dart';

import './providers/pictures.dart';
import './providers/barks.dart';
import './providers/songs.dart';
import './providers/image_controller.dart';
import './providers/sound_controller.dart';
import './providers/spinner_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await appStoragePath();
  HttpController();
  runApp(MyApp());
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
          value: SoundController(),
        ),
        ChangeNotifierProvider.value(
          value: ActiveWaveStreamer(),
        ),
        ChangeNotifierProvider.value(
          value: SpinnerState(),
        ),
        ChangeNotifierProvider.value(
          value: KaraokeCardDecorator(),
        ),
        ChangeNotifierProvider.value(
          value: User(),
        ),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Song Barker',
          theme: ThemeData(
            backgroundColor: Colors.amber[50],
            primarySwatch: MaterialColor(0xff234498, color),
            accentColor: Colors.purple[200],
            highlightColor: MaterialColor(0xff44bba4, color),
            // backgroundColor: MaterialColor(0xff367b92, color),
            fontFamily: 'Lato',
            buttonTheme: ButtonThemeData(
              minWidth: 200.0,
              height: 50.0,
              textTheme: ButtonTextTheme.primary,
              buttonColor: Colors.amber[200],
            ),
          ),
          // home: MainScreen(),
          home: MainScreen(),
          routes: {
            AuthenticationScreen.routeName: (ctx) => AuthenticationScreen(),
            MainScreen.routeName: (ctx) => MainScreen(),
            CreatableSongSelectScreen.routeName: (ctx) =>
                CreatableSongSelectScreen(),
            SelectSongAndPictureScreen.routeName: (ctx) =>
                SelectSongAndPictureScreen(),
            MenuScreen.routeName: (ctx) => MenuScreen(),
          }),
    );
  }
}
