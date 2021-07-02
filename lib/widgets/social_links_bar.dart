import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget socialLinksBar(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      RawMaterialButton(
        onPressed: null,
        child: Image.asset(
          "assets/logos/facebook256.png",
          height: 40,
          width: 40,
          fit: BoxFit.fitWidth,
        ),
        padding: const EdgeInsets.all(10.0),
      ),
      RawMaterialButton(
        onPressed: null,
        child: Image.asset(
          "assets/logos/Instagram_AppIcon_Aug2017.png",
          height: 40,
          width: 40,
          fit: BoxFit.fitWidth,
        ),
        padding: const EdgeInsets.all(10.0),
      ),
      RawMaterialButton(
        onPressed: null,
        child: Image.asset(
          "assets/logos/Twitter social icons - rounded square - blue.png",
          height: 40,
          width: 40,
          fit: BoxFit.fitWidth,
        ),
        padding: const EdgeInsets.all(10.0),
      ),
    ],
  );
}
