import 'package:K9_Karaoke/providers/karaoke_card_decorator.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/sound_controller.dart';
import 'package:K9_Karaoke/services/gcloud.dart';
import 'package:K9_Karaoke/services/rest_api.dart';
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
  KaraokeCardDecorator cardDecorator;

  void _handleUploadAndShare() async {
    saveArtwork();
    await Gcloud.uploadCardAssets(
        cards.current.audioFilePath, cards.current.decorationImagePath);
    // Upload card audio here too. then...
    // await RestAPI.createCard(decorationImageId, widget.cardAudioId,
    //     cards.current.amplitudes, cards.current.picture.fileId);
  }

  void saveArtwork() async {
    String decorationImageId = Uuid().v4();
    cards.current.decorationImagePath =
        await cardDecorator.cardPainter.capturePNG(decorationImageId, cards.current.framePath);
  }

  @override
  Widget build(BuildContext context) {
    soundController ??= Provider.of<SoundController>(context, listen: false);
    imageController ??= Provider.of<ImageController>(context, listen: false);
    cards = Provider.of<KaraokeCards>(context, listen: false);
    cardDecorator = Provider.of<KaraokeCardDecorator>(context, listen: false);

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15),
            child: TextField(
              onChanged: (name) {
                cards.current.recipientName = name;
              },
              onSubmitted: (_) => _handleUploadAndShare(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(),
                labelText: 'Recipient Name',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15),
            child: RawMaterialButton(
              onPressed: _handleUploadAndShare,
              child: Text("Share It!"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              elevation: 2.0,
              fillColor: Theme.of(context).primaryColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 2),
            ),
          ),
        ],
      ),
    );
  }
}
