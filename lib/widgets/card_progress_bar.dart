import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/screens/main_screen.dart';
import 'package:K9_Karaoke/screens/photo_library_screen.dart';
import 'package:K9_Karaoke/screens/set_picture_coordinates_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardProgressBar extends StatelessWidget {
  KaraokeCard card;
  CurrentActivity currentActivity;

  bool cardPictureIsStock() {
    return card.hasPicture ? !card.picture.isStock : false;
  }

  bool get _hasDecoration {
    return card.decorationImage != null || !card.decoration.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    card = Provider.of<KaraokeCards>(context, listen: false).current;
    currentActivity = Provider.of<CurrentActivity>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = screenWidth / 4.5;
    buttonWidth = buttonWidth > 150 ? 150 : buttonWidth;

    // print("screen width: $screenWidth");
    // print("button width: $buttonWidth");

    // tablet
    // screen width: 800.0
    // button width: 177.77777777777777

    // iphone 7
    // screen width: 320.0
    // button width: 71.11111111111111

    // galaxy s8
    // screen width: 360.0
    // button width: 80.0

    final primaryColor = Theme.of(context).primaryColor;

    Widget progressButton(
        {double offSetX,
        IconData stepIcon,
        CustomClipper buttonClip,
        CustomPainter outlinePainter,
        bool stepIsCompleted,
        bool isCurrentStep,
        Function navigateHere,
        bool canNavigate}) {
      return Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Transform.translate(
          offset: Offset(offSetX, 0),
          child: ClipPath(
            clipper: buttonClip,
            child: GestureDetector(
              onTap: canNavigate ? navigateHere : null,
              child: Opacity(
                opacity: canNavigate ? 1 : .3,
                child: Container(
                  color: stepIsCompleted
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  width: buttonWidth,
                  height: 30.0,
                  child: CustomPaint(
                    painter: outlinePainter,
                    child: Icon(
                      stepIcon,
                      color: stepIsCompleted
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    void navigateToSnap() {
      if (card.picture.isStock)
        Navigator.of(context).pushNamed(PhotoLibraryScreen.routeName);
      else
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                SetPictureCoordinatesScreen(card.picture, editing: true),
          ),
        );
      if (!card.picture.isStock)
        currentActivity.setCardCreationStep(CardCreationSteps.snap);
    }

    void navigateToSong() {
      currentActivity.setCardCreationStep(CardCreationSteps.song);
      // This is in case SetCoordinatesScreen is on the stack.
      Navigator.of(context).popUntil(ModalRoute.withName(MainScreen.routeName));
    }

    void navigateToSpeak() {
      if (card.hasASong) {
        currentActivity.setCardCreationStep(
            CardCreationSteps.speak, CardCreationSubSteps.seven);
      } else if (card.hasASongFormula)
        currentActivity.setCardCreationStep(CardCreationSteps.speak);
      else
        currentActivity.setCardCreationStep(
            CardCreationSteps.speak, CardCreationSubSteps.seven);
      // This is in case SetCoordinatesScreen is on the stack.
      Navigator.of(context).popUntil(ModalRoute.withName(MainScreen.routeName));
    }

    void navigateToStyle() {
      currentActivity.setCardCreationStep(CardCreationSteps.style);
      // This is in case SetCoordinatesScreen is on the stack.
      Navigator.of(context).popUntil(ModalRoute.withName(MainScreen.routeName));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        progressButton(
            offSetX: 13.333,
            stepIcon: CustomIcons.snap_quick,
            buttonClip: FirstButtonClipper(),
            outlinePainter: FirstOutlinePainter(
                currentActivity.isSnap ? Colors.blue : primaryColor),
            stepIsCompleted: card.hasPicture,
            isCurrentStep: currentActivity.isSnap,
            navigateHere: navigateToSnap,
            canNavigate: !card.isSaved),

        progressButton(
            offSetX: 5,
            stepIcon: CustomIcons.song_quick,
            buttonClip: MiddleButtonClipper(),
            outlinePainter: MiddleOutlinePainter(
                currentActivity.isSong ? Colors.blue : primaryColor),
            stepIsCompleted: card.hasASong || card.hasASongFormula,
            isCurrentStep: currentActivity.isSong,
            navigateHere: navigateToSong,
            canNavigate: card.hasPicture && !card.isSaved),

        // Can click only if creating a new song
        progressButton(
            offSetX: -5,
            stepIcon: CustomIcons.speak_quick,
            buttonClip: MiddleButtonClipper(),
            outlinePainter: MiddleOutlinePainter(
                currentActivity.isSpeak ? Colors.blue : primaryColor),
            stepIsCompleted: card.hasMessage,
            isCurrentStep: currentActivity.isSpeak,
            navigateHere: navigateToSpeak,
            // canNavigate: card.hasASongFormula || card.hasASong),
            canNavigate: card.hasPicture && !card.isSaved),

        progressButton(
            offSetX: -13.333,
            stepIcon: CustomIcons.style_quick,
            buttonClip: LastButtonClipper(),
            outlinePainter: LastOutlinePainter(
                currentActivity.isStyle ? Colors.blue : primaryColor),
            stepIsCompleted: _hasDecoration,
            isCurrentStep: currentActivity.isStyle,
            navigateHere: navigateToStyle,
            canNavigate: card.hasAudio && !card.isSaved),
      ],
    );
  }
}

void firstButtonPath(Size size, Path path) {
  double factor = size.height / 2;
  path.lineTo(0, size.height - factor);
  path.quadraticBezierTo(0, size.height, factor, size.height);
  path.lineTo(size.width - factor, size.height);
  path.lineTo(size.width, 0);
  path.lineTo(factor, 0);
  path.quadraticBezierTo(0, 0, 0, factor);
  path.close();
}

void middleButtonPath(Size size, Path path) {
  double factor = size.height / 2;
  path.lineTo(factor, 0);
  path.lineTo(0, size.height);
  path.lineTo(size.width - factor, size.height);
  path.lineTo(size.width, 0);
  path.close();
}

void lastButtonPath(Size size, Path path) {
  double factor = size.height / 2;
  path.lineTo(factor, 0);
  path.lineTo(0, size.height);
  path.lineTo(size.width - factor, size.height);
  path.quadraticBezierTo(
      size.width, size.height, size.width, size.height - factor);
  path.quadraticBezierTo(size.width, 0, size.width - factor, 0);
  path.lineTo(size.width, 0);
  path.lineTo(0, 0);
  path.close();
}

class FirstOutlinePainter extends CustomPainter {
  Color color;
  FirstOutlinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = color;
    Path path = Path();
    firstButtonPath(size, path);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class MiddleOutlinePainter extends CustomPainter {
  Color color;
  MiddleOutlinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = color;
    Path path = Path();
    middleButtonPath(size, path);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class LastOutlinePainter extends CustomPainter {
  Color color;
  LastOutlinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = color;
    Path path = Path();
    lastButtonPath(size, path);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class FirstButtonClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    final path = Path();
    firstButtonPath(size, path);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => false;
}

class MiddleButtonClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    var path = Path();
    middleButtonPath(size, path);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => false;
}

class LastButtonClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    var path = Path();
    lastButtonPath(size, path);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => false;
}
