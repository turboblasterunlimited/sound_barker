import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/barks.dart';

import './saved_bark.dart';


class SavedBarksGrid extends StatelessWidget {


  Widget build(BuildContext context) {
      final barks = Provider.of<Barks>(context);
      final savedBarks = barks.savedBarks;
      return GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: savedBarks.length,
        itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
          value: savedBarks[i],
          child: SavedBark(),
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
      );
    }
}