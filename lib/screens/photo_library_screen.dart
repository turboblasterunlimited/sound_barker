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
          iconTheme:
              IconThemeData(color: Theme.of(context).primaryColor, size: 30),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: Image.asset("assets/images/K9_logotype.png"),
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
                  Navigator.of(context).pushNamed(MenuScreen.routeName);
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              GestureDetector(
                onTap: () {},
                child: Row(children: <Widget>[
                  Icon(LineAwesomeIcons.arrow_left),
                  Text('Back'),
                ]),
              ),
              Center(
                child: Text('Photo Library',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600])),
              ),
            ],
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
