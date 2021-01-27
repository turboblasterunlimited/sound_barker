import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/the_user.dart';
import 'package:K9_Karaoke/screens/menu_screen.dart';
import 'package:K9_Karaoke/screens/photo_library_screen.dart';
import 'package:K9_Karaoke/widgets/custom_dialog.dart';
import 'package:K9_Karaoke/widgets/error_dialog.dart';

import 'package:K9_Karaoke/providers/card_decoration_image.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_card_decoration_controller.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/sound_controller.dart';
import 'package:K9_Karaoke/services/gcloud.dart';
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:K9_Karaoke/widgets/subscribe_dialog.dart';
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
  TheUser user;
  KaraokeCardDecorationController cardDecorator;
  CurrentActivity currentActivity;
  String _loadingMessage;
  String saveAndSendButtonText = "Save & Send";
  final messageNode = FocusNode();

  String recipientName = "You";
  bool hasEnvelope = false;
  String cardMessage = "";

  String shareLink;

  Future<void> _captureArtwork() async {
    if (cards.current.decorationImage != null) return;
    final decorationImage = CardDecorationImage();
    decorationImage.filePath = await cardDecorator.cardPainter
        .capturePNG(decorationImage.fileId, cards.current.framePath);
    cards.current.setDecorationImage(decorationImage);
  }

  void _handleShare() async {
    await Share.share(
        "K-9 Karaoke Card\n\n$cardMessage\n\n$shareLink\n\nCreated with K-9 Karaoke.",
        subject: "K-9 Karaoke");
    SystemChrome.restoreSystemUIOverlays();
    final snackBar = SnackBar(
      content: Text('Done Sharing!'),
    );
    Navigator.of(context).pop();
    Scaffold.of(context).showSnackBar(snackBar);
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

  Future<KaraokeCard> _createBaseCard(Function setDialogState) async {
    if (!cards.current.noFrameOrDecoration) {
      await _captureArtwork();
      setDialogState(() => _loadingMessage = "saving artwork...");
      _handleDecorationImage();
    }

    setDialogState(() => _loadingMessage = "saving sounds...");
    await _handleAudio();

    setDialogState(() => _loadingMessage = "creating link...");
    cards.current.uuid = Uuid().v4();
    cards.addCurrent();
    await RestAPI.createCard(cards.current);
    return cards.current;
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
      barrierDismissible: true,
      context: context,
      builder: (ctx) => StatefulBuilder(
          builder: (BuildContext modalContext, Function setDialogState) {
        return SingleChildScrollView(
            child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          contentPadding: EdgeInsets.only(top: 10.0),
          content: Container(
            width: 300.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Stack(
                  children: [
                    Positioned(
                      right: 20,
                      bottom: 5,
                      child: Icon(
                        CustomIcons.modal_share,
                        size: 42,
                        color: Colors.grey[300],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          "Share Card",
                          style: TextStyle(
                              color: Theme.of(modalContext).primaryColor,
                              fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  color: Colors.grey[300],
                  thickness: 2,
                ),
                Stack(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(18),
                          child: Icon(
                            CustomIcons.modal_paws_bottomright,
                            size: 42,
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                    _loadingMessage == null
                        ? hasEnvelope
                            ? Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 30.0, right: 30.0),
                                    child: TextField(
                                      onChanged: (name) {
                                        recipientName = name;
                                      },
                                      onSubmitted: (_) =>
                                          messageNode.requestFocus(),
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          height: 1,
                                          color: Colors.black),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        labelText: 'Recipient (optional)',
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 20,
                                        left: 30.0,
                                        right: 30.0,
                                        bottom: 20),
                                    child: TextField(
                                      textInputAction: TextInputAction.done,
                                      keyboardType: TextInputType.multiline,
                                      minLines: null,
                                      maxLines: null,
                                      focusNode: messageNode,
                                      onChanged: (message) {
                                        setState(() => cardMessage = message);
                                      },
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          height: 1,
                                          color: Colors.black),
                                      onSubmitted: (_) async {
                                        await _handleUploadAndShare(
                                            setDialogState);
                                      },
                                      decoration: InputDecoration(
                                        hintText:
                                            'Hi mom. Happy birthday from Spot.',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        labelText: 'Message (optional)',
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            // No Envelope
                            : Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  "Ready to Share!",
                                  style: TextStyle(
                                      fontSize: 24,
                                      color: Theme.of(context).primaryColor),
                                ),
                              )
                        : _loading(),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _loadingMessage != null
                            ? null
                            : () => _shareToClipboard(setDialogState),
                        child: Container(
                          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                          decoration: BoxDecoration(
                            color: Theme.of(modalContext).primaryColor,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(32.0),
                            ),
                          ),
                          child: Text(
                            "COPY LINK",
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: _loadingMessage != null
                            ? null
                            : () async {
                                _handleUploadAndShare(setDialogState);
                              },
                        child: Container(
                          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                          decoration: BoxDecoration(
                            color: Theme.of(modalContext).primaryColor,
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(32.0),
                            ),
                          ),
                          child: Text(
                            "SHARE",
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
      }),
    );
  }

  _envelopeDialog() async {
    await showDialog<Null>(
      barrierDismissible: true,
      context: context,
      builder: (ctx) => StatefulBuilder(
          builder: (BuildContext modalContext, Function setDialogState) {
        return CustomDialog(
          header: "Put your card in an envelope?",
          // headerSize: 18,
          iconPrimary: Icon(
            Icons.mail_outline_outlined,
            size: 60,
            color: Colors.grey[300],
          ),
          iconSecondary: Icon(
            CustomIcons.modal_paws_bottomright,
            size: 42,
            color: Colors.grey[300],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(
                "assets/images/card-in-envelope.png",
              ),
            ),
          ),
          isYesNo: true,
          primaryFunction: (con) {
            setState(() => hasEnvelope = true);
            Navigator.of(con).pop();
            _shareDialog();
          },
          secondaryFunction: (con) {
            Navigator.of(con).pop();
            _shareDialog();
          },
        );
      }),
    );
  }

  Future<void> _handleUploadAndShare(setDialogState) async {
    await _handleUpload(setDialogState);
    _handleShare();
  }

  Future<void> _handleUpload(setDialogState) async {
    var result;
    try {
      if (!cards.current.isSaved) {
        await _createBaseCard(setDialogState);
      }
      // Now create finished card
      result = await RestAPI.createFinishedCard(
          cards.current.uuid, recipientName, hasEnvelope);
      setDialogState(() {
        _loadingMessage = null;
        shareLink = result["url"];
      });
    } catch (e) {
      print("card upload Error: $e");
      showError(context, e);
    }
  }

  void _shareToClipboard(setDialogState) async {
    await _handleUpload(setDialogState);
    await Clipboard.setData(ClipboardData(text: shareLink));
    final snackBar = SnackBar(
      content: Text('Card link copied to Clipboard'),
    );
    Navigator.of(context).pop();
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void _backCallback() {
    if (cards.current.isSaved)
      return null;
    else
      return cards.current.isUsingDecorationImage
          ? currentActivity.setCardCreationSubStep(CardCreationSubSteps.one)
          : currentActivity.setPreviousSubStep();
  }

  _deleteDialog() async {
    return showDialog(
        context: context,
        builder: (ctx) {
          return CustomDialog(
            header: "Delete Card?",
            bodyText:
                "You will no longer be able to edit or share this card from the app.",
            primaryFunction: (BuildContext modalContext) async {
              await cards.remove(cards.current);
              Navigator.of(modalContext).pop();
              Navigator.of(modalContext).pushNamed(MenuScreen.routeName);
            },
            iconPrimary: Icon(
              CustomIcons.modal_trashcan,
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

  _subscribeDialog() {
    showDialog<Null>(
      context: context,
      builder: (ctx) =>
          StatefulBuilder(builder: (BuildContext ctx, Function setDialogState) {
        return SingleChildScrollView(child: SubscribeDialog());
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("building share interface");
    soundController ??= Provider.of<SoundController>(context, listen: false);
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
      child: Column(
        children: [
          InterfaceTitleNav(
              cards.current.isSaved ? "Share Again?" : "ALL DONE!",
              backCallback: cards.current.isSaved ? null : _backCallback),
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
                      onPressed:
                          user.subscribed || cards.currentIsFirst
                              ? _envelopeDialog
                              : _subscribeDialog,
                      child: Text(
                        cards.current.isSaved ? "Send Again" : "Save & Send",
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
                    if (cards.current.isSaved)
                      RawMaterialButton(
                        onPressed: () {
                          cards.newCurrent();
                          cardDecorator.reset();
                          currentActivity
                              .setCardCreationStep(CardCreationSteps.snap);
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
