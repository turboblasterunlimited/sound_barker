import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:song_barker/providers/tab_list_scroll_controller.dart';
import '../widgets/song_list.dart';
import '../widgets/bark_list.dart';
import '../widgets/picture_grid.dart';
import '../widgets/greeting_card_grid.dart';

class InterfaceSelector extends StatefulWidget {
  @override
  InterfaceSelectorState createState() => InterfaceSelectorState();
}

class InterfaceSelectorState extends State<InterfaceSelector> {
  double initialChildSize = 0.5;
  double minChildSize = 0.5;
  double maxChildSize = 0.7;
  double extent = 0.5;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        Provider.of<TabListScrollController>(context, listen: false).updateTabExtent(notification.extent);
        print("Notification extent: ${notification.extent}");
      },
      child: DraggableScrollableActuator(
        child: DraggableScrollableSheet(
          initialChildSize: initialChildSize,
          minChildSize: minChildSize,
          maxChildSize: maxChildSize,
          builder: (BuildContext ctx, ScrollController scrollController) {
            Provider.of<TabListScrollController>(context, listen: false)
                .setScrollController(scrollController);
            
            return Container(
              height: MediaQuery.of(context).size.longestSide * .7,
              color: Theme.of(ctx).primaryColor,
              child: DefaultTabController(
                length: 4,
                child: Column(
                  children: <Widget>[
                    // MaterialButton(
                    //   onPressed: () {
                    //     // setState(() => )
                    //   },
                    // ),
                    Material(
                      color: Theme.of(ctx).accentColor,
                      child: TabBar(
                        tabs: [
                          Tab(text: "SOUNDS"),
                          Tab(text: "SONGS"),
                          Tab(text: "IMAGES"),
                          Tab(text: "CARDS"),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          BarkList(),
                          SongList(),
                          PictureGrid(),
                          GreetingCardGrid(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
