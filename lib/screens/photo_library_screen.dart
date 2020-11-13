import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'package:K9_Karaoke/providers/pictures.dart';
import 'package:K9_Karaoke/screens/camera_or_upload_screen.dart';
import 'package:K9_Karaoke/screens/menu_screen.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:K9_Karaoke/widgets/picture_card.dart';

class PhotoLibraryScreen extends StatefulWidget {
  static const routeName = 'photo-library-screen';

  @override
  _PhotoLibraryScreenState createState() => _PhotoLibraryScreenState();
}

class _PhotoLibraryScreenState extends State<PhotoLibraryScreen> {
  Pictures pictures;
  KaraokeCards cards;

  List<Widget> _pictureGridTiles(List<Picture> pics,
      [usersDisplayedPictures, stateSetter]) {
    List<Widget> widgets = [];
    pics.forEach((picture) {
      widgets.add(PictureCard(
          picture, pictures, usersDisplayedPictures, stateSetter,
          key: UniqueKey()));
    });
    return widgets;
  }

  List<Widget> _usersPictureGridTiles() {
    List<Widget> result = [];
    // each picture gets a reference to all the user's own displayed pictues, for handling delete animation: 'result'.
    _pictureGridTiles(pictures.all, result, () => setState(() => {}))
        .forEach((picCard) => result.add(picCard));
    result.insert(0, _addPictureButton());
    return result;
  }

  Widget _addPictureButton() {
    return Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, CameraOrUploadScreen.routeName);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(Icons.add,
                      color: Theme.of(context).primaryColor, size: 50),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _backCallback() {
    if (cards.current != null && cards.current.hasPicture)
      Navigator.of(context).pop();
    else
      Navigator.of(context).pushNamed(MenuScreen.routeName);
  }

  SliverChildListDelegate _dogGridDivider(String label) {
    return SliverChildListDelegate(
      [
        Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 15),
          child: Text(
            label,
            style:
                TextStyle(fontSize: 20, color: Theme.of(context).primaryColor),
          ),
        ),
        Divider(
          indent: 10,
          endIndent: 10,
          color: Theme.of(context).primaryColor,
          thickness: 3,
        ),
      ],
    );
  }

  Widget build(BuildContext context) {
    pictures = Provider.of<Pictures>(context, listen: false);
    cards = Provider.of<KaraokeCards>(context, listen: false);
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomPadding: false,
      appBar: customAppBar(context, noName: true),
      body: Container(
        // appbar offset
        padding: EdgeInsets.only(top: 80),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/create_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: InterfaceTitleNav(
                "CHOOSE PHOTO",
                titleSize: 20,
                backCallback: _backCallback,
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverList(delegate: _dogGridDivider("Your Dogs")),
                  SliverGrid.count(
                    // key: _listKey,
                    children: _usersPictureGridTiles(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                  ),
                  SliverList(delegate: _dogGridDivider("Stock Dogs")),
                  SliverGrid.count(
                    children: _pictureGridTiles(pictures.stockPictures),
                    crossAxisCount: 3,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
