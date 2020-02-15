import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../providers/barks.dart';

class MakeSongsScreen extends StatelessWidget {
  static const routeName = 'make-songs';
  @override
  Widget build(BuildContext context) {
    // final barks = Provider.of<Bark>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Song Barker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: AppDrawer(),
      body: Center(

        //GridView.builder of all the barks

      ),
    );
  }
}