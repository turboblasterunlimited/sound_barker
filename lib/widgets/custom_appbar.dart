import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/screens/menu_screen.dart';
import 'package:K9_Karaoke/widgets/photo_name_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

Widget customAppBar(BuildContext context,
    {bool noName = false,
    bool isMenu = false,
    bool isMainMenu = false,
    Widget nameInput,
    String pageTitle}) {
  final cards = Provider.of<KaraokeCards>(context);
  final currentActivity = Provider.of<CurrentActivity>(context);
  var notificationPadding = MediaQuery.of(context).padding.top;
  var screenWidth = MediaQuery.of(context).size.width;
  var logoWidth = (screenWidth / 4.5) - notificationPadding;
  logoWidth = logoWidth > 100 ? 100 : logoWidth;

  Widget _getMiddleSpace() {
    if (nameInput != null)
      return nameInput;
    else if (pageTitle != null)
      return Expanded(
        child: Row(
          children: [
            Spacer(),
            Text(pageTitle,
                style: TextStyle(fontSize: 18, color: Colors.black)),
            Spacer(),
          ],
        ),
      );
    else if (isMenu || noName || cards?.current == null)
      return Spacer();
    else
      return PhotoNameInput(cards.current.picture, cards.setCurrentName);
  }

  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    automaticallyImplyLeading: false, // Don't show the leading button
    toolbarHeight: 80 - notificationPadding,
    titleSpacing: 0,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 10),
          child: SvgPicture.asset("assets/logos/K9_logotype.svg",
              width: logoWidth),
        ),
        _getMiddleSpace(),
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: isMainMenu && !currentActivity.isCreateCard
              ? null
              : isMainMenu || pageTitle != null
                  ? IconButton(
                      icon: Icon(
                        CustomIcons.hambooger_close,
                        color: Colors.black,
                        size: 35,
                      ),
                      onPressed: () {
                        SystemChrome.setEnabledSystemUIOverlays([]);
                        Navigator.of(context).pop();
                      },
                    )
                  : IconButton(
                      icon: Icon(
                        CustomIcons.hambooger,
                        color: Colors.black,
                        size: 30,
                      ),
                      onPressed: () {
                        SystemChrome.setEnabledSystemUIOverlays([]);
                        Navigator.of(context).pushNamed(MenuScreen.routeName);
                      },
                    ),
        ),
      ],
    ),
  );
}
