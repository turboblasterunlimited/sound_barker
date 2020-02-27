import 'package:flutter/material.dart';
// import 'package:song_barker/widgets/image_transformer.dart';

import '../widgets/pet_tabview.dart';
import '../widgets/app_drawer.dart';
import '../widgets/pet_image.dart';

class RecordBarksScreen extends StatelessWidget {
  static const routeName = 'record-bark-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Song Barker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: <Widget>[
          PetImage(),
          PetTabview(),
        ],
      ),
    );
  }
}

Widget _buildProfileImage() {
  return Center(
    child: Container(
      width: 140.0,
      height: 140.0,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              'http://cdn.akc.org/content/article-body-image/samoyed_puppy_dog_pictures.jpg'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(80.0),
        border: Border.all(
          color: Colors.white,
          width: 10.0,
        ),
      ),
    ),
  );
}
