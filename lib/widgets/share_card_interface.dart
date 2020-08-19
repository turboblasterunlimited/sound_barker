import 'dart:io';

import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_card_decoration_controller.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/sound_controller.dart';
import 'package:K9_Karaoke/services/gcloud.dart';
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:share/share.dart';
import 'package:uuid/uuid.dart';

class ShareCardInterface extends StatefulWidget {
  @override
  _ShareCardInterfaceState createState() => _ShareCardInterfaceState();
}

class _ShareCardInterfaceState extends State<ShareCardInterface> {
  SoundController soundController;
  ImageController imageController;
  KaraokeCards cards;
  KaraokeCardDecorationController cardDecorator;
  CurrentActivity currentActivity;
  String recipientName;

  void _handleUploadAndShare() async {
    await saveArtwork();
    final bucketFps = await Gcloud.uploadCardAssets(
        cards.current.decorationImage, cards.current.audio);

    await RestAPI.createCardDecorationImage(
        cards.current.decorationImage.fileId, bucketFps["image"]);
    await RestAPI.createCardAudio(
        cards.current.audio.fileId, bucketFps["audio"]);
    await RestAPI.createCard(cards.current);
  }

  Future<void> saveArtwork() async {
    if (cards.current.decorationImage.filePath != null) return;
    final decorationImageId = Uuid().v4();
    final decorationImagePath = await cardDecorator.cardPainter
        .capturePNG(decorationImageId, cards.current.framePath);
    cards.setCurrentDecorationImagePath(decorationImagePath);
  }

  Future<void> _uploadAndCreateDecorationImage() async {
    String imageBucketFp =
        await Gcloud.uploadDecorationImage(cards.current.decorationImage);
    await RestAPI.createCardDecorationImage(
        cards.current.decorationImage.fileId, imageBucketFp);
  }

  Future<void> _uploadAndCreateCardAudio() async {
    String audioBucketFp = await Gcloud.uploadCardAudio(cards.current.audio);
    await RestAPI.createCardAudio(cards.current.audio.fileId, audioBucketFp);
  }

  Future<void> _updateCard() async {
    bool changedAudio, changedDecoration = false;
    if (cards.current.shouldDeleteOldDecoration) {
      cards.current.deleteOldDecoration();
      saveArtwork();
      _uploadAndCreateDecorationImage();
      cards.current.shouldDeleteOldDecoration = false;
      changedDecoration = true;
    }
    if (cards.current.oldCardAudio != null) {
      cards.current.deleteOldAudio();
      _uploadAndCreateCardAudio();
      changedAudio = true;
    }
    if (changedAudio || changedDecoration)
      RestAPI.updateCard(cards.current, changedAudio, changedDecoration);
  }

  Future<void> _createCard() {
    cards.current.uuid = Uuid().v4();
  }

  Function shareDialog() {
    return () => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 30, right: 30, bottom: 15),
                    child: TextField(
                      onChanged: (name) {
                        recipientName = name;
                      },
                      onSubmitted: (_) => _handleUploadAndShare(),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        labelText: 'Recipient Name',
                      ),
                    ),
                  ),
                  RawMaterialButton(
                    onPressed: _handleUploadAndShare,
                    child: Text("Share", style: TextStyle(color: Colors.white)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 2.0,
                    fillColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 2),
                  ),
                ],
              ),
            ),
          ),
        );
  }

  Future<void> _saveCard() {
    if (_editingCard()) {
      _updateCard();
    } else {
      _createCard();
    }
  }

  bool _editingCard() {
    return cards.current.uuid != null;
  }

  @override
  Widget build(BuildContext context) {
    soundController ??= Provider.of<SoundController>(context, listen: false);
    imageController ??= Provider.of<ImageController>(context, listen: false);
    cards = Provider.of<KaraokeCards>(context, listen: true);
    cardDecorator =
        Provider.of<KaraokeCardDecorationController>(context, listen: false);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);

    return Column(
      children: [
        interfaceTitleNav(context, "",
            backCallback: currentActivity.setPreviousSubStep),
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15),
          child: RawMaterialButton(
            onPressed: () async {
              await _saveCard();
              showDialog(
                context: context,
                builder: shareDialog(),
              );
            },
            child: Text("Save Card", style: TextStyle(color: Colors.white)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            elevation: 2.0,
            fillColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 2),
          ),
        ),
      ],
    );
  }
}
