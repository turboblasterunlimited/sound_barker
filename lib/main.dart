import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/pet_details_screen.dart';
import './screens/record_barks_screen.dart';
import './screens/make_songs_screen.dart';

import './providers/images.dart';
import './providers/barks.dart';
import './providers/songs.dart';
import './providers/image_controller.dart';
import './providers/sound_controller.dart';



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

    // Song song = Song(name: "Test", fileId: "9b6f1c1b-f9af-4430-b75c-3326ca121cc9", filePath: "/Users/tovinewman/Library/Developer/CoreSimulator/Devices/3FD6B298-8ED0-40F2-955F-5C12BB3D6AB4/data/Containers/Data/Application/7FF25BC5-0F53-41FE-9227-39C11056F60A/Documents/9b6f1c1b-f9af-4430-b75c-3326ca121cc9.aac");
    // Pet charles = Pet(name: "Charles");
    // charles.songs.add(song);
    // Pets allPets = Pets();
    // allPets.all.add(charles);

    // Songs songs = Songs();
    // songs.all.add(song);

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
          value: Images(),
        ),
        ChangeNotifierProvider.value(
          value: SoundController(),
        ),
      ],
      child: MaterialApp(
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
          home: RecordBarksScreen(),
          routes: {
            RecordBarksScreen.routeName: (ctx) => RecordBarksScreen(),
            PetDetailsScreen.routeName: (ctx) => PetDetailsScreen(),
            MakeSongsScreen.routeName: (ctx) => MakeSongsScreen(),
          }),
    );
  }
}
