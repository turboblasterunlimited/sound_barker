import 'dart:io';

import 'package:K9_Karaoke/classes/card_decoration_image.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_card_decoration_controller.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/sound_controller.dart';
import 'package:K9_Karaoke/services/gcloud.dart';
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
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
  String _loadingMessage;
  String shareLink;

  Future<void> saveArtwork() async {
    if (cards.current.decorationImage != null) return;
    final decorationImage = CardDecorationImage();
    decorationImage.filePath = await cardDecorator.cardPainter
        .capturePNG(decorationImage.fileId, cards.current.framePath);
    cards.current.setDecorationImage(decorationImage);
  }

  Future<void> _uploadAndCreateDecorationImage() async {
    cards.current.decorationImage.bucketFp =
        await Gcloud.uploadDecorationImage(cards.current.decorationImage);
    await RestAPI.createCardDecorationImage(cards.current.decorationImage);
  }

  Future<void> _uploadAndCreateCardAudio() async {
    cards.current.audio.bucketFp =
        await Gcloud.uploadCardAudio(cards.current.audio);
    await RestAPI.createCardAudio(cards.current.audio);
  }

  Future<void> _updateCard() async {
    bool changed = false;
    if (cards.current.shouldDeleteOldDecoration) {
      cards.current.deleteOldDecorationImage();
      saveArtwork();
      _uploadAndCreateDecorationImage();
      cards.current.shouldDeleteOldDecoration = false;
      changed = true;
    }
    if (cards.current.oldCardAudio != null) {
      cards.current.deleteOldAudio();
      _uploadAndCreateCardAudio();
      changed = true;
    }
    if (changed) RestAPI.updateCard(cards.current);
  }

  Future<void> _createCard() async {
    await saveArtwork();
    print("checkpoint");
    setState(() => _loadingMessage = "saving artwork...");
    cards.current.decorationImage.bucketFp =
        await Gcloud.uploadDecorationImage(cards.current.decorationImage);
            print("checkpoint 1");

    setState(() => _loadingMessage = "saving sounds...");
    cards.current.audio.bucketFp =
        await Gcloud.uploadCardAudio(cards.current.audio);
            print("checkpoint 2");

    setState(() => _loadingMessage = "creating link...");
    await RestAPI.createCardDecorationImage(cards.current.decorationImage);
    await RestAPI.createCardAudio(cards.current.audio);
    cards.current.uuid = Uuid().v4();
    var responseData = await RestAPI.createCard(cards.current);
    setState(() => _loadingMessage = null);
    setState(() => shareLink =
        "https://www.thedogbarksthesong.ml/card/" + responseData["uuid"]);
    print("Share Link $shareLink");
  }

  Widget _shareLink() {
    return Text(shareLink);
  }

  Widget _loading() {
    return Column(
      children: [
        SpinKitWave(),
        Text(_loadingMessage,
            style: TextStyle(color: Theme.of(context).primaryColor)),
      ],
    );
  }

  _shareDialog() async {
    await showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Share'),
        content: Container(
          height: 200,
          child: Stack(
            children: [
              if (shareLink == null && _loadingMessage == null) Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
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
                  Center(
                    child: RawMaterialButton(
                      onPressed: _handleUploadAndShare,
                      child:
                          Text("Share", style: TextStyle(color: Colors.white)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 2.0,
                      fillColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 2),
                    ),
                  ),
                ],
              ),
              if (_loadingMessage != null) _loading()
              else if (shareLink != null) _shareLink(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleUploadAndShare() async {
    if (_editingCard()) {
      await _updateCard();
    } else {
      await _createCard();
    }
  }

  bool _editingCard() {
    return cards.current.uuid != null;
  }

  void _backCallback() {
    return cards.current.isUsingDecorationImage
        ? currentActivity.setCardCreationSubStep(CardCreationSubSteps.one)
        : currentActivity.setPreviousSubStep();
  }

  @override
  Widget build(BuildContext context) {
    soundController ??= Provider.of<SoundController>(context, listen: false);
    imageController ??= Provider.of<ImageController>(context, listen: false);
    cards = Provider.of<KaraokeCards>(context, listen: true);
    cardDecorator =
        Provider.of<KaraokeCardDecorationController>(context, listen: false);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);

    // File(cards.current.picture.filePath);

    // print();

    return Column(
      children: [
        interfaceTitleNav(context, "", backCallback: _backCallback),
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15),
          child: RawMaterialButton(
            onPressed: _shareDialog,
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
