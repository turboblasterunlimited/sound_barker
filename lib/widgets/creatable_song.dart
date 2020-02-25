import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/barks.dart';
import '../widgets/bark_select_card.dart';

class CreatableSong extends StatelessWidget {
  void createSong(context) async {
    String barkName;
    String barkId;
    Barks barks = Provider.of<Barks>(context, listen: false);
    await showDialog<Null>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Select Bark'),
        contentPadding: EdgeInsets.all(10),
        titlePadding: EdgeInsets.all(10),
        children: <Widget>[
          Visibility(
            visible: barks.all.length != 0,
            child: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: barks.all.length,
              itemBuilder: (ctx, i) => BarkSelectCard(i, barks.all[i]),
              ),
            ),
          ),
          Visibility(
            visible: barks.all.length > 0,
            child: Text("You have no barks recorded."),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 4,
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: ListTile(
          leading: CircleAvatar(
            child: Padding(
              padding: EdgeInsets.all(5),
              child: FittedBox(
                child: Text('\$1'),
              ),
            ),
          ),
          title: Text("Happy Birthday"),
          subtitle: Text('to you...'),
          trailing: IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              createSong(context);
            },
          ),
        ),
      ),
    );
  }
}
