import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/barks_screen.dart';
import './providers/barks.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Barks(),
        ),
      ],
      child: MaterialApp(
          title: 'Song Barker',
          theme: ThemeData(
            primarySwatch: Colors.teal,
            accentColor: Colors.lightBlueAccent,
            fontFamily: 'Lato',
            buttonTheme: ButtonThemeData(
              minWidth: 200.0,
              height: 50.0,
              textTheme: ButtonTextTheme.primary,
              buttonColor: Colors.amber[200],
            ),
          ),
          home: BarksScreen(),
          routes: {
            BarksScreen.routeName: (ctx) => BarksScreen(),
          }),
    );
  }
}
