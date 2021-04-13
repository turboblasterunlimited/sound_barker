import 'package:flutter/material.dart';

class Info extends StatelessWidget {
  final italic =
      TextStyle(fontStyle: FontStyle.italic, color: Colors.black, fontSize: 13);
  final title =
      TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 22);
  final bold =
      TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 15);
  final reg =
      TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 13);
  final link = TextStyle(
      decoration: TextDecoration.underline,
      color: Colors.blue,
      fontWeight: FontWeight.w400,
      fontSize: 13);

  final text = '''
1. Click on NEW CARD\n
2. Select the + (plus sign) box.\n
3. Choose Camera to take a photo of your dog or choose Upload to choose an existing photo that you have stored on your phone.  For best results choose a photo of the dog looking straight at the camera with its mouth closed.\n
4. Crop the photo:  One finger moves the photo in the box and two fingers enlarges or shrinks the photo within the box.  Press Done.  Then type in the name of your dog.\n
5.SET FACE:  Use the designated markers to identify the four points around the head, the two markets to identify the eyes, and the three mouth points to identify the left, center, and right side of the mouth  Press the blue check box when completed.  The app will take you to the MOUTH & LIPS screen.  You likely will want to make some adjustments to the mouth.  Press Back to return to the SET FACE screen to make adjustments and then press the blue check box to return to the MOUTH & LIPS screen. \n
6.MOUTH & LIPS:  Use the sliders to choose the mouth color, size of lips, and lips color.  press the blue check box when done.\n
7.SELECT SONG:  Listen to the songs by pressing a song title in the large ovals.  Elect the song that you want to use by clicking on the square select box left of the song that you want.  Pressing the select square will bring you to the next step.\n
If you want to  make a greeting card with just a talking message without a song press Skip and the app will jump to step-13b.\n  
8.CAPTURE BARKS:  If you have a video on your phone of your dog barking press UPLOAD AUDIO and select the video from your phone.  Make sure that the barks are on the first 15-seconds of the video.  After selecting the video press ADD BARKS AND CONTINUE.\n
If you do not have a video with existing barks from your dog you can use the RECORD AUDIO button.  Press STOPand then ADD BARKS AND CONTINUE.

9. SELECT SHORT BARK:  This is the most important bark that will be the main melody bark for your song.  Listen to the available short barks by pressing the large ovals.  Select the one short bark you want with the select square left of the bark that you want. 

For best results choose a clean sounding bark without strange sounds that the app might not have sections well.

10. SELECT MEDIUM BARK:  This bark will appear on the end of some versus or choruses.

11. SELECT FINALE BARK:  This bark will be the ending bark.

(For any of the short, medium, or finale barks you can also select from Stock Barks or FX for our inventory of barks and noises.)

12.  CHOOSE STYLE:  Some people prefer the dog to hit all of the notes in the song and will choose Make my dog hit all the notes.  This option might make some of the barks sound unnatural to your ear.  If the higher and lower pitched notes don’t sound good to you then select Make my dog sound realistic for a less broad range of notes.  Press the blue play arrow on the dogs photo to listen to the song with your dog singing.  If you like it press the blue check box to move forward to step-13a.

If you want to make changes press the red X to go back to choose a different style.  If some of the barks don’t sound good then click Back from the CHOOSE STYLE screen and select different barks.

13a.  PRE-SONG MESSAGE:  Press Record and use your human voice to record a message that will play right before the song starts.  Press Stop when you’re done recording.  Adjust pitch, speed, or add effects using the sliders.  Press the blue play arrow on the dog’s photo to hear the message and make possible pitch and speed and effects adjustments with the sliders.  When you are happy with the sound of the message press ADD MESSAGE AND CONTINUE to go to step-14.

13b  If your K-9 Karaoke greeting card does not include a song the screen title will be CARD MESSAGE.  Record a human voice message tor your greeting card.    Press Stop when you’re done recording.  Adjust pitch, speed, or add effects using the sliders.  Press the blue play arrow on the dog’s photo to hear the message and make possible adjustments with the sliders.  When you are happy with the sound of the message press ADD MESSAGE AND CONTINUE to go to step-14.

14.  CHOOSE FRAME:  Scroll left or right to select the art frame that you want to surround the photo of your dog.

15.  TYPE / DRAW:  This screen is for adding your own text or drawings onto the photo and art frame.  Press Skip if you do not want to add text or drawings.

16.  ALL DONE! :  This is your last chance to make any changes.  Press the blue play arrow to listen to your audio and confirm that the art frame looks good.  If it looks good press Save & Send to go to step-17.  Once you press Save & Sendyou cannot make anymore changes to the card.

If you want to make changes go Back or use the four camera, music note, microphone, art gallery buttons to navigate to make changes.

17.  Put your card in an envelope?:  Choose YES if you want the recipient of the card see your card emerged out of an envelope.  This is a nice feature if you are using text/SMS or email to send the card to someone or to a group of people.  If you select YES you will be taken to step-18a.

If you plan to post the card on social media or YouTube you might prefer to not have the card emerging from an envelope in which case you might select NO.  If you select NO you will be taken to step-18b.

18a.  SHARE CARD (with envelope):  You have the option of adding the recipients name on the outside of the envelope.  You also have the option of writing a message that will be included in conjunction with a link to the card.  The recipient might think the card is spam or a junk email and typing a short message here will help to make the recipient realize that the card is not spam or junk.

When done with the recipient’s name and typed message press Share to send it via text/SMS, email, WhatsApp, Facebook, etc. or Copy link to paste it somewhere.

18b,  SHARE CARD (without envelope):   Share to send it via text/SMS, email, WhatsApp, Facebook, etc. or Copy link to paste it somewhere.

''';
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0, left: 16.0, bottom: 16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            color: Colors.white,
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  'Instructions\n',
                  style: title,
                  textAlign: TextAlign.center,
                ),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(text: text, style: reg),
                    ],
                  ),
                ),
//                Text(text, style: reg),
                Text('\n\n '),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
