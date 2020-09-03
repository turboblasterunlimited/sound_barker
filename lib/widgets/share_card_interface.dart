import 'dart:io';
import 'package:K9_Karaoke/widgets/error_dialog.dart';
import 'package:intl/intl.dart';

import 'package:K9_Karaoke/providers/card_decoration_image.dart';
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
import 'package:flutter/services.dart';

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
  String recipientName = "You";
  String _loadingMessage;
  String shareLink;

  Future<void> _captureArtwork() async {
    if (cards.current.decorationImage != null) return;
    final decorationImage = CardDecorationImage();
    decorationImage.filePath = await cardDecorator.cardPainter
        .capturePNG(decorationImage.fileId, cards.current.framePath);
    cards.current.setDecorationImage(decorationImage);
  }

  Future<void> _uploadAndCreateDecorationImage() async {
    cards.current.decorationImage.bucketFp = await Gcloud.upload(
        cards.current.decorationImage.filePath, "decoration_images");
    await RestAPI.createCardDecorationImage(cards.current.decorationImage);
  }

  Future<void> _uploadAndCreateCardAudio() async {
    cards.current.audio.bucketFp =
        await Gcloud.upload(cards.current.audio.filePath, "card_audios");
    await RestAPI.createCardAudio(cards.current.audio);
  }

  Future<void> _updateCard(Function setDialogState) async {
    bool changed = false;
    if (cards.current.shouldDeleteOldDecoration) {
      setDialogState(() => _loadingMessage = "updating artwork...");
      await cards.current.deleteOldDecorationImage();
      await _captureArtwork();
      await _uploadAndCreateDecorationImage();
      cards.current.shouldDeleteOldDecoration = false;
      changed = true;
    }
    if (cards.current.oldCardAudio != null) {
      setDialogState(() => _loadingMessage = "saving sounds...");
      await cards.current.deleteOldAudio();
      await _uploadAndCreateCardAudio();
      changed = true;
    }
    if (changed) {
      var responseData = await RestAPI.updateCard(cards.current);
      _handleShare(responseData["uuid"], setDialogState);
    } else {
      _handleShare(cards.current.uuid, setDialogState);
    }
  }

  void _handleShare(uuid, setDialogState) {
    String name = toBeginningOfSentenceCase(cards.current.picture.name);
    setDialogState(() => _loadingMessage = null);
    setDialogState(() => shareLink =
        "https://www.thedogbarksthesong.ml/card/$uuid?recipient_name=$recipientName");
    print("Share Link $shareLink");
    Share.share(
        "$name has a message for you.\n\n$shareLink\n\nCreated with K-9 Karaoke.",
        subject: "$name has a message for you.");
  }

  Future<void> _handleAudio() async {
    cards.current.audio.bucketFp =
        await Gcloud.upload(cards.current.audio.filePath, "card_audios");
    await RestAPI.createCardAudio(cards.current.audio);
  }

  Future<void> _handleDecorationImage() async {
    cards.current.decorationImage.bucketFp = await Gcloud.upload(
        cards.current.decorationImage.filePath, "decoration_images");
    await RestAPI.createCardDecorationImage(cards.current.decorationImage);
  }

  Future<void> _createCard(Function setDialogState) async {
    await _captureArtwork();
    setDialogState(() => _loadingMessage = "saving artwork...");
    _handleDecorationImage();

    setDialogState(() => _loadingMessage = "saving sounds...");
    await _handleAudio();

    setDialogState(() => _loadingMessage = "creating link...");
    cards.current.uuid = Uuid().v4();
    cards.addCurrent();
    var responseData = await RestAPI.createCard(cards.current);
    _handleShare(responseData["uuid"], setDialogState);
  }

  Widget _shareLink() {
    return Column(
      children: [
        GestureDetector(
            onTap: () => Clipboard.setData(ClipboardData(text: shareLink))
                    .then((result) {
                  final snackBar = SnackBar(
                    content: Text('Card link copied to Clipboard'),
                  );
                  Scaffold.of(context).showSnackBar(snackBar);
                }),
            child: Row(
              children: [
                Icon(Icons.content_copy),
                Flexible(
                  child: Text(shareLink),
                )
              ],
            )),
      ],
    );
  }

  Widget _loading() {
    return Column(
      children: [
        SpinKitWave(color: Theme.of(context).primaryColor),
        Text(_loadingMessage,
            style: TextStyle(color: Theme.of(context).primaryColor)),
      ],
    );
  }

  _shareDialog() async {
    await showDialog<Null>(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
              builder: (BuildContext context, Function setDialogState) {
            return AlertDialog(
              title: Text('Share'),
              content: Container(
                height: 200,
                child: Stack(
                  children: [
                    if (_loadingMessage == null)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            onChanged: (name) {
                              recipientName = name;
                            },
                            onSubmitted: (_) {
                              _handleUploadAndShare(setDialogState);
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                              labelText: 'Recipient Name',
                            ),
                          ),
                          Center(
                            child: RawMaterialButton(
                              onPressed: () {
                                _handleUploadAndShare(setDialogState);
                              },
                              child: Text(
                                  "Share${shareLink != null ? ' Again' : ''}",
                                  style: TextStyle(color: Colors.white)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              elevation: 2.0,
                              fillColor: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40.0, vertical: 2),
                            ),
                          ),
                          if (shareLink != null && _loadingMessage == null)
                            _shareLink(),
                        ],
                      ),
                    if (_loadingMessage != null) _loading()
                  ],
                ),
              ),
            );
          });
        });
  }

  Future<void> _handleUploadAndShare(Function setDialogState) async {
    if (!cards.current.audio.exists)
      return showError(context, "Card has no audio");

    if (_editingCard()) {
      await _updateCard(setDialogState);
    } else {
      await _createCard(setDialogState);
    }
    SystemChrome.restoreSystemUIOverlays();
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
            child: Text("Save & Send", style: TextStyle(color: Colors.white)),
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
