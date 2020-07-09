import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/pictures.dart';
import 'package:K9_Karaoke/screens/menu_screen.dart';
import 'package:K9_Karaoke/widgets/picture_card.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';

class PhotoLibraryScreen extends StatefulWidget {
  static const routeName = 'photo-library-screen';

  @override
  _PhotoLibraryScreenState createState() => _PhotoLibraryScreenState();
}

class _PhotoLibraryScreenState extends State<PhotoLibraryScreen> {
  Pictures pictures;

  Widget build(BuildContext context) {
    print("building photo library...");
    pictures = Provider.of<Pictures>(context, listen: false);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      resizeToAvoidBottomPadding: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false, // Don't show the leading button
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset("assets/logos/K9_logotype.png", width: 100),
              // Your widgets here
            ],
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: RawMaterialButton(
                child: Icon(
                  Icons.menu,
                  color: Colors.black,
                  size: 30,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                onPressed: () {
                  Navigator.of(context).popAndPushNamed(MenuScreen.routeName);
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Stack(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Row(children: <Widget>[
                    Icon(LineAwesomeIcons.angle_left),
                    Text('Back'),
                  ]),
                ),
                Center(
                  child: Text('Photo Library',
                      style: TextStyle(fontSize: 20, color: Colors.grey[600])),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: GridView.builder(
                controller: null,
                padding: const EdgeInsets.all(10),
                itemCount: pictures.all.length,
                itemBuilder: (_, i) => ChangeNotifierProvider.value(
                  value: pictures.all[i],
                  key: UniqueKey(),
                  child: PictureCard(i, pictures.all[i], pictures),
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  // childAspectRatio: 3 / 2,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
