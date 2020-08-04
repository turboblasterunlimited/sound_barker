import 'dart:io';

import 'package:K9_Karaoke/providers/pictures.dart';
import 'package:K9_Karaoke/screens/camera_or_upload_screen.dart';
import 'package:K9_Karaoke/screens/menu_screen.dart';
import 'package:K9_Karaoke/screens/set_picture_coordinates_screen.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:K9_Karaoke/tools/cropper.dart';
import 'package:K9_Karaoke/widgets/picture_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';

class PhotoLibraryScreen extends StatefulWidget {
  static const routeName = 'photo-library-screen';

  @override
  _PhotoLibraryScreenState createState() => _PhotoLibraryScreenState();
}

class _PhotoLibraryScreenState extends State<PhotoLibraryScreen> {
  Pictures pictures;

  List<Widget> _pictureGridTiles(List<Picture> pics) {
    List<Widget> widgets = [];
    pics.asMap().forEach((i, picture) {
      widgets.add(PictureCard(picture, pictures));
    });
    return widgets;
  }

  List<Widget> _usersPictureGridTiles() {
    List<Widget> result = _pictureGridTiles(pictures.all);
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
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                border: Border.all(
                  color: Colors.black,
                  width: 8,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.add,
                      color: Theme.of(context).primaryColor, size: 20),
                  Text(
                    "Your Dog Here",
                    style: TextStyle(
                        fontSize: 18, color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  SliverChildListDelegate _dogGridDivider(String label) {
    return SliverChildListDelegate(
      [
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
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
    return Scaffold(
      extendBodyBehindAppBar: true,
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
              padding: const EdgeInsets.all(20.0),
              child: Stack(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .popAndPushNamed(MenuScreen.routeName);
                    },
                    child: Row(children: <Widget>[
                      Icon(LineAwesomeIcons.angle_left),
                      Text('Back'),
                    ]),
                  ),
                  Center(
                    child: Text('PHOTO LIBRARY',
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).primaryColor)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: _dogGridDivider("Your Dogs")
                  ),
                  SliverGrid.count(
                    children: _usersPictureGridTiles(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                  ),
                  SliverList(
                    delegate: _dogGridDivider("Stock Dogs")
                  ),
                  SliverGrid.count(
                    children: _pictureGridTiles(pictures.stockPictures),
                    crossAxisCount: 3,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                  )
                ],
              ),
            )
            // Expanded(
            //   child: Center(
            //     child: GridView.builder(
            //       padding: const EdgeInsets.all(10),
            //       itemCount: pictures.stockPictures.length,
            // itemBuilder: (_, i) => ChangeNotifierProvider.value(
            //   value: pictures.stockPictures[i],
            //   key: UniqueKey(),
            //   child: PictureCard(i, pictures.stockPictures[i], pictures),
            // ),
            //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //         crossAxisCount: 3,
            //         // childAspectRatio: 3 / 2,
            //         crossAxisSpacing: 3,
            //         mainAxisSpacing: 3,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
