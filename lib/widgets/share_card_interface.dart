import 'package:K9_Karaoke/globals.dart';
import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/the_user.dart';
import 'package:K9_Karaoke/screens/menu_screen.dart';
import 'package:K9_Karaoke/screens/photo_library_screen.dart';
import 'package:K9_Karaoke/screens/subscription_screen.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
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
  String recipientName = "You";
  String _loadingMessage;
  String shareLink;
  String saveAndSendButtonText = "Save & Send";
  final messageNode = FocusNode();
  bool isSent = false;
  String cardMessage = "";

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

  Future<String> _updateCard(Function setDialogState) async {
    print("updating card");
    bool changed = false;
    if (cards.current.shouldDeleteOldDecoration) {
      setDialogState(() => _loadingMessage = "updating artwork...");
      await cards.current.deleteOldDecorationImage();
      cards.current.shouldDeleteOldDecoration = false;
      changed = true;
    }
    if (!cards.current.noFrameOrDecoration) {
      print("capturing artwork...");
      print("decoration is empty: ${cards.current.decoration.isEmpty}");
      print("has frame: ${cards.current.hasFrame}");
      await _captureArtwork();
      await _uploadAndCreateDecorationImage();
      changed = true;
    }
    if (cards.current.oldCardAudio != null) {
      setDialogState(() => _loadingMessage = "saving sounds...");
      await cards.current.deleteOldAudio();
      setDialogState(() => _loadingMessage = "saving sounds...");
      await _uploadAndCreateCardAudio();
      changed = true;
    }
    if (changed) {
      var responseData = await RestAPI.updateCard(cards.current);
      return responseData["uuid"];
    } else {
      return cards.current.uuid;
    }
  }

  String get _getCleanedRecipientName {
    return recipientName.replaceAll(RegExp(r'[\s+]'), '%20');
  }

  void _handleShare(uuid, setDialogState) async {
    _getShareLink(uuid, setDialogState);
    await Share.share("$cardMessage\n\n$shareLink\n\nCreated with K-9 Karaoke.",
        subject: "K-9 Karaoke greeting card");
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

  Future<String> _createCard(Function setDialogState) async {
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
    var responseData = await RestAPI.createCard(cards.current);
    return responseData["uuid"];
  }

  void _getShareLink(uuid, setDialogState) {
    setDialogState(() {
      _loadingMessage = null;
      shareLink =
          "https://www.$serverURL/card/$uuid?recipient_name=$_getCleanedRecipientName";
    });
  }

  void _shareToClipboard(setDialogState) async {
    if (shareLink == null) {
      String uuid = await _handleUpload(setDialogState);
      _getShareLink(uuid, setDialogState);
    }
    Clipboard.setData(ClipboardData(text: shareLink)).then((result) {
      final snackBar = SnackBar(
        content: Text('Card link copied to Clipboard'),
      );
      Navigator.of(context).pop();
      Scaffold.of(context).showSnackBar(snackBar);
    });
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

  _subscribeDialog() async {
    await showDialog<Null>(
      context: context,
      builder: (ctx) => StatefulBuilder(
          builder: (BuildContext context, Function setDialogState) {
        return SingleChildScrollView(
            child: CustomDialog(
          header: "Subscribe!",
          bodyText:
              "You've reached your save & share limit for a free account. Subscribe to save and share more cards!",
          secondaryFunction: (BuildContext modalContext) {
            Navigator.of(modalContext).pop();
          },
          primaryFunction: (BuildContext modalContext) async {
            Navigator.of(modalContext).pop();
            Navigator.pushNamed(context, SubscriptionScreen.routeName);
          },
          iconPrimary: Icon(
            LineAwesomeIcons.plus_circle,
            size: 42,
            color: Colors.grey[300],
          ),
          iconSecondary: Icon(
            CustomIcons.modal_paws_topleft,
            size: 42,
            color: Colors.grey[300],
          ),
          isYesNo: true,
        ));
      }),
    );
  }

  _shareDialog() async {
    setState(() => isSent = true);
    await showDialog<Null>(
      barrierDismissible: true,
      context: context,
      builder: (ctx) => StatefulBuilder(
          builder: (BuildContext context, Function setDialogState) {
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
                          "Sharing is Caring",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
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
                        ? Column(
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 30.0, right: 30.0),
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
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    labelText: 'Recipient Name',
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
                                    await _handleUploadAndShare(setDialogState);
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    labelText: 'Message',
                                  ),
                                ),
                              ),
                            ],
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
                            color: Theme.of(context).primaryColor,
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
                            color: Theme.of(context).primaryColor,
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

  Future<void> _handleUploadAndShare(setDialogState) async {
    if (shareLink != null)
      return _handleShare(cards.current.uuid, setDialogState);
    String uuid = await _handleUpload(setDialogState);
    _handleShare(uuid, setDialogState);
  }

  Future<String> _handleUpload(Function setDialogState) async {
    try {
      if (!cards.current.audio.exists)
        showError(context, "Card has no audio");
      else if (_editingCard()) {
        print("editing card");
        return await _updateCard(setDialogState);
      } else {
        print("creating new card");
        return await _createCard(setDialogState);
      }
    } catch (e) {
      print("upload card error: $e");
      showError(context, e);
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

  @override
  Widget build(BuildContext context) {
    soundController ??= Provider.of<SoundController>(context, listen: false);
    imageController ??= Provider.of<ImageController>(context, listen: false);
    cards = Provider.of<KaraokeCards>(context, listen: true);
    user = Provider.of<TheUser>(context, listen: false);
    cardDecorator =
        Provider.of<KaraokeCardDecorationController>(context, listen: false);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);
    // File(cards.current.picture.filePath);
    // print();
    return Container(
      // shares height with decorator interface to maintain art canvas art alignment.
      height: 170,
      child: Column(
        children: [
          InterfaceTitleNav("ALL DONE!", backCallback: _backCallback),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RawMaterialButton(
                      // IF USER IS NOT SUBSCRIBED AND OUT OF FREE CARDS,
                      // USER IS PREVENTED FROM SAVING/SENDING AND PROMPTED TO SUBSCRIBE.
                      onPressed: user.hasActiveSubscription ||
                              cards.current == cards.all.first
                          ? _shareDialog
                          : _subscribeDialog,
                      child: Text(
                        isSent ? "Send Again" : "Save & Send",
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
                    if (isSent)
                      RawMaterialButton(
                        onPressed: () {
                          cards.newCurrent();
                          cardDecorator.reset();
                          currentActivity
                              .setCardCreationStep(CardCreationSteps.snap);
                          currentActivity.startCreateCard();
                          Navigator.of(context)
                              .popAndPushNamed(PhotoLibraryScreen.routeName);
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
                if (cards.current.uuid != null)
                  RawMaterialButton(
                    onPressed: _deleteDialog,
                    child: Text(
                      "Delete",
                      style: TextStyle(color: Colors.white),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 2.0,
                    fillColor: Theme.of(context).errorColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 2),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
