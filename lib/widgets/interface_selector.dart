import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:song_barker/providers/tab_list_scroll_controller.dart';
import '../widgets/song_list.dart';
import '../widgets/bark_list.dart';

class InterfaceSelector extends StatefulWidget {
  @override
  InterfaceSelectorState createState() => InterfaceSelectorState();
}

class InterfaceSelectorState extends State<InterfaceSelector> {
  double initialChildSize;
  double minChildSize;
  double maxChildSize = 0.8;
  double extent;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double bottomPadding = MediaQuery.of(context).padding.bottom;
    double topPadding = MediaQuery.of(context).padding.top;
    extent = (screenHeight - screenWidth + bottomPadding + topPadding) /
        (screenHeight + bottomPadding + topPadding);
    initialChildSize = extent;
    minChildSize = extent;

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        Provider.of<TabListScrollController>(context, listen: false)
            .updateTabExtent(notification.extent);
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
              color: Colors.white,
              child: DefaultTabController(
                length: 2,
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
                          Tab(
                            child: Text(
                              "BARKS",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Tab(
                            child: Text(
                              "SONGS",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          BarkList(),
                          SongList(),
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
