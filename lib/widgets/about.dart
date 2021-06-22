import 'package:flutter/material.dart';

class About extends StatelessWidget {
  final italic =
      TextStyle(fontStyle: FontStyle.italic, color: Colors.black, fontSize: 20);
  final title =
      TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 22);
  final bold =
      TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 20);
  final reg =
      TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 20);
  final link = TextStyle(
      decoration: TextDecoration.underline,
      color: Colors.blue,
      fontWeight: FontWeight.w400,
      fontSize: 18);

  final text = '''
K-9 Karaoke is an app for making greeting cards in which your dog sings/barks songs and talks. Take a photo of your dog and identify points on its face to make its mouth open, eyes blink, and head move.  Then choose a song from our song library.  Upload a video of your dog barking and the app automatically sections individual barks and then choose which individual barks you want to use for your song.  Record a human language greeting.  You can also make a card without a song and just have a human voice message.  Choose a pre-made art frame and if you want add your own text or drawings on it.  Then you're done!  Save your K-9 Karaoke greeting card and send it to someone via text/SMS, email, WhatsApp, etc. or post it on social media.  BARK! BARK! BARK!

The first K-9 Karaoke greeting card is free.  After that then please subscribe to either a monthly or yearly account for unlimited use.   ''';
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    var screenSize = "Your screen is " +
        (screenWidth).round().toString() +
        " by " +
        (screenHeight).round().toString() +
        ".\n\n";

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0, left: 16.0, bottom: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 400,
            padding: EdgeInsets.symmetric(horizontal: 8),
            color: Color.fromRGBO(255, 255, 255, 0.3),
            child: ListView(
              shrinkWrap: true,
              children: [
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(text: screenSize, style: reg),
                      TextSpan(text: text, style: reg),
                      TextSpan(text: '\n\n', style: reg),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
