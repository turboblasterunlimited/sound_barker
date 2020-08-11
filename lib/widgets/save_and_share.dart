import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/sound_controller.dart';
import 'package:K9_Karaoke/services/gcloud.dart';
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

class SaveAndShare extends StatefulWidget {
  @override
  _SaveAndShareState createState() => _SaveAndShareState();
}

class _SaveAndShareState extends State<SaveAndShare> {
  SoundController soundController;
  ImageController imageController;
  KaraokeCards cards;
  double canvasLength;
  final textController = TextEditingController();
  bool _isPlaying = false;

  @override
  void dispose() {
    stopPlayback();
    super.dispose();
  }

  void stopPlayback() {
    if (_isPlaying) {
      imageController.stopAnimation();
      soundController.stopPlayer();
      setState(() => _isPlaying = false);
    }
  }

  void playCard() {
    soundController.startPlayer(cards.current.audioFilePath, stopPlayback);
    imageController.mouthTrackSound(amplitudes: cards.current.amplitudes);
    setState(() => _isPlaying = true);
  }

  void uploadAndShare() async {
    await Gcloud.uploadCardAssets(
        cards.current.audioFilePath, cards.current.decorationImagePath);
    // Upload card audio here too. then...
    // await RestAPI.createCard(decorationImageId, widget.cardAudioId,
    //     cards.current.amplitudes, cards.current.picture.fileId);
  }

  @override
  Widget build(BuildContext context) {
    soundController ??= Provider.of<SoundController>(context);
    imageController ??= Provider.of<ImageController>(context, listen: false);
    canvasLength ??= MediaQuery.of(context).size.width;
    cards = Provider.of<KaraokeCards>(context);

    return Expanded(
      child: Center(),
    );
  }
}
