import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/all_songs_screen.dart';
import './screens/pet_details_screen.dart';
import './screens/record_barks_screen.dart';
import './screens/make_songs_screen.dart';

import './providers/pet.dart';
import './providers/user.dart';
import './providers/bark.dart';
import './providers/song.dart';

void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Pet(),
        ),
        ChangeNotifierProvider.value(
          value: User(),
        ),
        // ChangeNotifierProvider.value(
        //   value: Bark(),
        // ),
        // ChangeNotifierProvider.value(
        //   value: Song(),
        // ),

      ],
      child: MaterialApp(
          title: 'Song Barker',
          theme: ThemeData(
            primarySwatch: Colors.teal,
            accentColor: Colors.lightBlueAccent,
            fontFamily: 'Lato',
            buttonTheme: ButtonThemeData(
              minWidth: 200.0,
              height: 50.0,
              textTheme: ButtonTextTheme.primary,
              buttonColor: Colors.amber[200],
            ),
          ),
          home: RecordBarksScreen(),
          routes: {
            RecordBarksScreen.routeName: (ctx) => RecordBarksScreen(),
            PetDetailsScreen.routeName: (ctx) => PetDetailsScreen(),
            AllSongsScreen.routeName: (ctx) => AllSongsScreen(),
            MakeSongsScreen.routeName: (ctx) => MakeSongsScreen(),

          }),
    );
  }
}
