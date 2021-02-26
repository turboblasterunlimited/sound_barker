// import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/screens/main_screen.dart';
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:K9_Karaoke/widgets/error_dialog.dart';
import 'package:K9_Karaoke/widgets/loading_half_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareScreen extends StatefulWidget {
  static const routeName = 'share-screen';
  final bool withEnvelope;

  ShareScreen({this.withEnvelope});

  @override
  _ShareScreenState createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final messageNode = FocusNode();
  String recipientName = "You";
  String cardMessage = "";
  String shareLink;
  KaraokeCard card;
  String loadingMessage;

  void _handleShare() async {
    await Share.share(
        "K-9 Karaoke Card\n\n$cardMessage\n\n$shareLink\n\nCreated with K-9 Karaoke.",
        subject: "K-9 Karaoke");
    SystemChrome.restoreSystemUIOverlays();
    final snackBar = SnackBar(
      content: Text('Done Sharing!'),
    );
    Navigator.of(context).popUntil(ModalRoute.withName(MainScreen.routeName));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  Future<void> _handleUploadAndShare(ctx) async {
    await _handleUploadFinishedCard(ctx);
    _handleShare();
  }

  _handleUploadFinishedCard(ctx) async {
    try {
      var result = await RestAPI.createFinishedCard(
          card.uuid, recipientName, widget.withEnvelope);
      setState(() {
        loadingMessage = null;
        shareLink = result["url"];
      });
    } catch (e) {
      print("finished card upload Error: $e");
      showError(ctx, e);
    }
  }

  void _shareToClipboard(ctx) async {
    await _handleUploadFinishedCard(ctx);
    await Clipboard.setData(ClipboardData(text: shareLink));
    final snackBar = SnackBar(
      content: Text('Card link copied to Clipboard'),
    );
    Scaffold.of(ctx).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    card = Provider.of<KaraokeCards>(context, listen: false).current;
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      // appBar: CustomAppBar(isMenu: true, pageTitle: "Support"),
      // Background image
      body: Builder(builder: (BuildContext ctx) {
        return Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/backgrounds/menu_background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigator.of(ctx).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(children: <Widget>[
                    Icon(LineAwesomeIcons.angle_left),
                    Text('Back'),
                  ]),
                ),
              ),
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
                            color: Theme.of(ctx).primaryColor, fontSize: 26),
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                color: Colors.grey[300],
                thickness: 2,
              ),
              loadingMessage != null
                  ? LoadingHalfScreenWidget(loadingMessage)
                  : widget.withEnvelope
                      ? Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 20, left: 30.0, right: 30.0, bottom: 20),
                              child: TextField(
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.multiline,
                                minLines: null,
                                maxLines: null,
                                onChanged: (name) {
                                  recipientName = name;
                                },
                                onSubmitted: (_) => messageNode.requestFocus(),
                                style: TextStyle(
                                    fontSize: 15.0,
                                    height: 1,
                                    color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'Recipient name on envelope.',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 30.0, right: 30.0),
                              child: TextField(
                                focusNode: messageNode,
                                onChanged: (message) {
                                  cardMessage = message;
                                },
                                onSubmitted: (_) async {
                                  messageNode.unfocus();
                                },
                                style: TextStyle(
                                    fontSize: 15.0, color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: "Message to introduce card.",
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 20, 30),
                              child: Text(
                                "This message will help the recipient realize that this greeting card is not spam.",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(ctx).accentColor),
                              ),
                            ),
                          ],
                        )
                      // Without envelope
                      : Center(),
              // BUTTONS
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RawMaterialButton(
                    onPressed: loadingMessage != null
                        ? null
                        : () async {
                            _handleUploadAndShare(ctx);
                          },
                    child: Text(
                      "Share",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 2.0,
                    fillColor: Theme.of(ctx).primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 20),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                  ),
                  RawMaterialButton(
                    onPressed: loadingMessage != null
                        ? null
                        : () => _shareToClipboard(ctx),
                    // constraints:
                    //     BoxConstraints(minWidth: 52.0, minHeight: 30.0),
                    child: Text(
                      "Copy Link",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).accentColor,
                        fontSize: 15,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                      side: BorderSide(
                          color: Theme.of(context).accentColor, width: 3),
                    ),
                    elevation: 2.0,
                    fillColor: null,
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
