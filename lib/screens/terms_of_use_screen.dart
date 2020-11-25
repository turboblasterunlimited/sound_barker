import 'package:K9_Karaoke/widgets/terms_of_use.dart';
import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  static const routeName = 'terms-of-use-screen';
  final italic =
      TextStyle(fontStyle: FontStyle.italic, color: Colors.black, fontSize: 13);
  final title =
      TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 22);
  final bold =
      TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 13);
  final reg = TextStyle(color: Colors.black, fontWeight: FontWeight.w200);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/backgrounds/menu_background.png"),
          fit: BoxFit.cover,
        ),
      ),
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          TermsOfUse(),
        ],
      ),
    );
  }
}
