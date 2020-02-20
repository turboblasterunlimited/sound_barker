import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/all_songs_screen.dart';
import './screens/pet_details_screen.dart';
import './screens/record_barks_screen.dart';
import './screens/make_songs_screen.dart';

import './providers/pets.dart';
import './providers/user.dart';
import './providers/barks.dart';
import './providers/songs.dart';

void main() {
  // final User user = User();
  // Pet pet1 = Pet(
  //     name: "Fido",
  //     imageUrl:
  //         'http://cdn.akc.org/content/article-body-image/samoyed_puppy_dog_pictures.jpg');
  // Pet pet2 = Pet(
  //     name: "Bilbo",
  //     imageUrl:
  //         'https://s3.amazonaws.com/cdn-origin-etr.akc.org/wp-content/uploads/2018/01/12201051/cute-puppy-body-image.jpg');
  // user.addPet(pet1);
  // user.addPet(pet2);


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Pets(),
        ),
        ChangeNotifierProvider.value(
          value: Barks(),
        ),
        ChangeNotifierProvider.value(
          value: Songs(),
        ),
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
