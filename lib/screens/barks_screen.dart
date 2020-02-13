import 'package:flutter/material.dart';
import '../widgets/pet_grid.dart';
import '../widgets/app_drawer.dart';
import '../widgets/record_button.dart';

class BarksScreen extends StatefulWidget {
  static const routeName = 'bark-screen';

  @override
  _BarksScreenState createState() => _BarksScreenState();
}

class _BarksScreenState extends State<BarksScreen> {
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
                  child: PetGrid(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
