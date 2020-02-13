import 'package:flutter/material.dart';

import '../widgets/barks_grid.dart';
import '../widgets/app_drawer.dart';
import '../widgets/record_button.dart';

class RecordBarksScreen extends StatefulWidget {
  static const routeName = 'record-bark-screen';

  @override
  _RecordBarksScreenState createState() => _RecordBarksScreenState();
}

class _RecordBarksScreenState extends State<RecordBarksScreen> {
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
          Expanded(
            child: RecordButton(),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  // child: AllBarksGrid(), // need to change PetsGrid back to barks grid, this will be grid of all barks.
                ),
              ],
            ),
          ),
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
