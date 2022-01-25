import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/the_user.dart';
import 'package:K9_Karaoke/screens/envelope_screen.dart';
import 'package:K9_Karaoke/screens/photo_library_screen.dart';
import 'package:K9_Karaoke/widgets/custom_dialog.dart';
import 'package:K9_Karaoke/widgets/error_dialog.dart';

import 'package:K9_Karaoke/providers/card_decoration_image.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_card_decoration_controller.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/flutter_sound_controller.dart';
import 'package:K9_Karaoke/services/gcloud.dart';
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:K9_Karaoke/widgets/loading_quarter_screen_widget.dart';
import 'package:K9_Karaoke/widgets/subscribe_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'package:uuid/uuid.dart';

class ShareCardInterface extends StatefulWidget {
  @override
  _ShareCardInterfaceState createState() => _ShareCardInterfaceState();
}

class _ShareCardInterfaceState extends State<ShareCardInterface> {
  FlutterSoundController? soundController;
  ImageController? imageController;
  KaraokeCards? cards;
  TheUser? user;
  late KaraokeCardDecorationController cardDecorator;
  late CurrentActivity currentActivity;
  String? loadingMessage;
  String saveAndSendButtonText = "Save & Send";

  @override
  void dispose() {
    soundController!.stopPlayer();
    imageController!.stopAnimation();
    super.dispose();
  }

  Future<void> _captureArtwork() async {
    if (cards!.current!.decorationImage != null) return;
    final decorationImage = CardDecorationImage();
    decorationImage.filePath = await cardDecorator.cardPainter!
        .capturePNG(decorationImage.fileId!, cards!.current!.framePath);
    cards!.current!.setDecorationImage(decorationImage);
  }

  Future<void> _handleAudio() async {
    cards!.current!.audio!.bucketFp =
        await Gcloud.upload(cards!.current!.audio!.filePath!, "card_audios");
    await RestAPI.createCardAudio(cards!.current!.audio);
  }

  Future<void> uploadDecorationImage() async {
    cards!.current!.decorationImage!.bucketFp = await Gcloud.upload(
        cards!.current!.decorationImage!.filePath!, "decoration_images");
    await RestAPI.createCardDecorationImage(cards!.current!.decorationImage!);
  }

  // ignore: missing_return
  Future<void> createBaseCard() async {
    try {
      if (!cards!.current!.noFrameOrDecoration) {
        setState(() => loadingMessage = "saving artwork...");
        await _captureArtwork();
        await uploadDecorationImage();
      }
      setState(() => loadingMessage = "saving sounds...");
      await _handleAudio();
      print("After handle audio");
      setState(() => loadingMessage = "creating link...");
      cards!.current!.uuid = Uuid().v4();
      cards!.addCurrent();
      await RestAPI.createCard(cards!.current!);
      loadingMessage = null;
    } catch (e) {
      cards!.current!.uuid = null;
      showError(context, e.toString());
    }
  }

  void _backCallback() {
    if (cards!.current!.isSaved)
      return null;
    else
      return cards!.current!.isUsingDecorationImage
          ? currentActivity.setCardCreationSubStep(CardCreationSubSteps.one)
          : currentActivity.setPreviousSubStep();
  }

  _subscribeDialog() {
    showDialog<Null>(
      context: context,
      builder: (ctx) =>
          StatefulBuilder(builder: (BuildContext ctx, Function setDialogState) {
        return SingleChildScrollView(child: SubscribeDialog());
      }),
    );
  }

  void handleSaveAndSend() async {
    if (!user!.subscribed && !cards!.currentIsFirst) return _subscribeDialog();
// jmf -- 18Oct2021
    // if (cards.current.uuid == null) await createBaseCard();
    // Navigator.of(context).pushNamed(EnvelopeScreen.routeName);
    _warnThenSaveAndSend();
  }

  void _warnThenSaveAndSend() async {
    if (cards!.current!.uuid != null) {
      Navigator.of(context).pushNamed(EnvelopeScreen.routeName);
    } else {
      return showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return CustomDialog(
              header: "Are you sure you're done?",
              bodyText: "You can no longer edit your card after this step!",
              primaryFunction: (BuildContext modalContext) async {
                print("Editing done");
                await createBaseCard();
                Navigator.of(modalContext)
                    .popAndPushNamed(EnvelopeScreen.routeName);
              },
              secondaryFunction: (BuildContext modalContext) async {
                print("Editing continues");
                Navigator.of(modalContext).pop();
              },
              iconPrimary: Icon(
                CustomIcons.modal_logout,
                size: 42,
                color: Colors.grey[300],
              ),
              iconSecondary: Icon(
                CustomIcons.modal_paws_topleft,
                size: 42,
                color: Colors.grey[300],
              ),
              isYesNo: true,
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("building share interface");
    soundController ??=
        Provider.of<FlutterSoundController>(context, listen: false);
    imageController ??= Provider.of<ImageController>(context, listen: false);
    cards ??= Provider.of<KaraokeCards>(context, listen: true);
    user ??= Provider.of<TheUser>(context, listen: false);
    cardDecorator =
        Provider.of<KaraokeCardDecorationController>(context, listen: false);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);
    // File(cards.current.picture.filePath);
    // print();
    return Container(
      // shares height with decorator interface to maintain art canvas art alignment.
      height: 130,
      child: loadingMessage != null
          ? LoadingQuarterScreenWidget(loadingMessage!, 25)
          : Column(
              children: [
                InterfaceTitleNav(
                    title:
                        cards!.current!.isSaved ? "Share Again?" : "ALL DONE!",
                    // Can't go back and edit if saved.
                    backCallback:
                        cards!.current!.isSaved ? null : _backCallback),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RawMaterialButton(
                            // IF USER IS NOT SUBSCRIBED AND OUT OF FREE CARDS,
                            // USER IS PREVENTED FROM SAVING/SENDING AND PROMPTED TO SUBSCRIBE.
                            onPressed: handleSaveAndSend,
                            child: Text(
                              cards!.current!.isSaved
                                  ? "Send Again"
                                  : "Save & Send",
                              style: TextStyle(color: Colors.white),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            elevation: 2.0,
                            fillColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40.0, vertical: 2),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                          ),
                          if (cards!.current!.isSaved)
                            RawMaterialButton(
                              onPressed: () {
                                cards!.newCurrent();
                                cardDecorator.reset();
                                currentActivity.setCardCreationStep(
                                    CardCreationSteps.snap);
                                currentActivity.startCreateCard();
                                Navigator.of(context)
                                    .pushNamed(PhotoLibraryScreen.routeName);
                              },
                              child: Text(
                                "New Card",
                                style: TextStyle(color: Colors.white),
                              ),
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
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
