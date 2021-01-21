import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/screens/subscription_screen.dart';
import 'package:K9_Karaoke/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

class SubscribeDialog extends StatelessWidget {
  final String dialogText;
  SubscribeDialog([this.dialogText]);
  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      header: "Subscribe!",
      bodyText: dialogText != null
          ? dialogText
          : "You've reached your save & share limit for a free account. Subscribe to save and share more cards!",
      secondaryFunction: (BuildContext modalContext) {
        Navigator.of(modalContext).pop();
      },
      primaryFunction: (BuildContext modalContext) {
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
    );
  }
}
