import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grouped_buttons/grouped_buttons.dart';

import '../providers/barks.dart';

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
            child: RadioButtonGroup(
              labels: barks.all.map((bark) => bark.name).toList(),
              onSelected: (String selected) {
                barkId = barks.allBarkNameIdPairs()[selected];
                barkName = selected;
                Navigator.of(ctx).pop();
              },
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
          subtitle: Text('Do it.'),
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
