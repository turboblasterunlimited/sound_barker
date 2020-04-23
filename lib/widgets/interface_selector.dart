import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:song_barker/providers/tab_list_scroll_controller.dart';
import 'package:song_barker/widgets/singing_image.dart';
import '../widgets/song_list.dart';
import '../widgets/bark_list.dart';
import '../widgets/picture_grid.dart';
import '../widgets/greeting_card_grid.dart';

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
    extent = (screenHeight - screenWidth) / screenHeight;
    initialChildSize = extent;
    minChildSize = extent;

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        Provider.of<TabListScrollController>(context, listen: false).updateTabExtent(notification.extent);
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
