import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/the_user.dart';
import 'package:K9_Karaoke/screens/menu_screen.dart';
import 'package:K9_Karaoke/widgets/photo_name_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool noName;
  final bool isMenu;
  final bool isMainMenu;
  Widget? nameInput;
  String? pageTitle;
  CustomAppBar(
      {Key? key,
      this.noName = false,
      this.isMenu = false,
      this.isMainMenu = false,
      this.nameInput,
      this.pageTitle})
      // jmf -- changed to make tool bar bigger
//      : preferredSize = Size.fromHeight(kToolbarHeight),
      : preferredSize = Size.fromHeight(80),
        super(key: key);

  @override
  final Size preferredSize; // default is 56.0

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  KaraokeCards? cards;
  TheUser? currentUser;
  var notificationPadding;
  var screenWidth;
  var screenHeight;
  var logoWidth;
  var logoHeight;
  var logoTopOffset;
  bool? showActionIcon;

  Widget _getMiddleSpace() {
    if (widget.nameInput != null)
      return widget.nameInput!;
    else if (widget.pageTitle != null)
      return Expanded(
        child: Row(
          children: [
            Spacer(),
            Text(
              widget.pageTitle!,
              style: TextStyle(
                  fontSize: 22, color: Theme.of(context).primaryColor),
            ),
            Spacer(),
          ],
        ),
      );
    else if (widget.isMenu || widget.noName || cards?.current == null)
      return Spacer();
    else
      return PhotoNameInput(cards!.setCurrentName);
  }

  getLogoWidth() {
    var width = (screenWidth / 3) - logoTopOffset;

    return width > 100.0 ? 100.0 : width;
//    return width;
  }

  @override
  Widget build(BuildContext context) {
    cards ??= Provider.of<KaraokeCards>(context);
    currentUser ??= Provider.of<TheUser>(context);
    notificationPadding ??= MediaQuery.of(context).padding.top;
    screenWidth ??= MediaQuery.of(context).size.width;
    screenHeight ??= MediaQuery.of(context).size.height;
    logoTopOffset = 10.0;
    logoWidth ??= getLogoWidth();
    //logoWidth = 40.0;
    //logoHeight = 20.0;
    showActionIcon ??=
        currentUser!.email != null && (cards!.hasPicture || !widget.isMainMenu);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false, // Don't show the leading button
      //toolbarHeight: 80 - notificationPadding,
      toolbarHeight: 120.0,
      titleSpacing: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: logoTopOffset, left: 10),
            child:
                SvgPicture.asset("assets/logos/k-9K-TM.svg", width: logoWidth),
          ),
          _getMiddleSpace(),
          Padding(
            padding: const EdgeInsets.only(right: 10.0, bottom: 10),
            child: widget.isMainMenu || widget.pageTitle != null
                ? Visibility(
                    maintainSize: true,
                    maintainState: true,
                    maintainAnimation: true,
                    visible: showActionIcon!,
                    child: IconButton(
                      icon: Icon(
                        CustomIcons.hambooger,
                        color: Colors.black,
                        size: 30,
                      ),
                      // IconButton(
                      //   icon: Icon(
                      //     widget.isMainMenu
                      //         ? CustomIcons.hambooger_close
                      //         : LineAwesomeIcons.arrow_circle_left,
                      //     color: Colors.black,
                      //     size: 35,
                      //   ),
                      onPressed: () {
                        SystemChrome.setEnabledSystemUIOverlays([]);
                        Navigator.of(context).pushNamed(MenuScreen.routeName);
                        //Navigator.of(context).pop();
                      },
                    ),
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
}
