import 'dart:async';

import 'package:K9_Karaoke/providers/card_audio.dart';
import 'package:K9_Karaoke/providers/card_decoration_image.dart';
import 'package:K9_Karaoke/providers/creatable_songs.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/the_user.dart';
import 'package:K9_Karaoke/screens/about_screen.dart';
import 'package:K9_Karaoke/screens/account_screen.dart';
import 'package:K9_Karaoke/screens/authentication_screen.dart';
import 'package:K9_Karaoke/screens/camera_or_upload_screen.dart';
import 'package:K9_Karaoke/screens/check_authentication_screen.dart';
import 'package:K9_Karaoke/screens/envelope_screen.dart';
import 'package:K9_Karaoke/screens/menu_screen.dart';
import 'package:K9_Karaoke/screens/my_cards.dart';
import 'package:K9_Karaoke/screens/photo_library_screen.dart';
import 'package:K9_Karaoke/screens/privacy_policy_screen.dart';
import 'package:K9_Karaoke/screens/retrieve_data_screen.dart';
import 'package:K9_Karaoke/screens/subscription_screen.dart';
import 'package:K9_Karaoke/screens/support_screen.dart';
import 'package:K9_Karaoke/screens/terms_of_use_screen.dart';
import 'package:custom_paddle_slider_value_indicator_shape/custom_paddle_slider_value_indicator_shape.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/providers/karaoke_card_decoration_controller.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:flutter/rendering.dart';
import 'package:sentry/sentry.dart';

import 'package:K9_Karaoke/providers/active_wave_streamer.dart';
import 'package:K9_Karaoke/services/http_controller.dart';
import './screens/main_screen.dart';

import './providers/pictures.dart';
import './providers/barks.dart';
import './providers/songs.dart';
import './providers/image_controller.dart';
import './providers/sound_controller.dart';

final sentry = SentryClient(
    dsn:
        "https://31ded6d00ce54b96b36f5606649333a1@o460285.ingest.sentry.io/5460225");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await appStoragePath();
  HttpController();
  // Sentry
  runZonedGuarded(
    () => runApp(MyApp()),
    (error, stackTrace) async {
      await sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    },
  );

  // Sentry
  FlutterError.onError = (details, {bool forceReport = false}) {
    sentry.captureException(
      exception: details.exception,
      stackTrace: details.stack,
    );
  };
}

class MyApp extends StatelessWidget {
  Map<int, Color> color = {
    50: Color.fromRGBO(136, 14, 79, .1),
    100: Color.fromRGBO(136, 14, 79, .2),
    200: Color.fromRGBO(136, 14, 79, .3),
    300: Color.fromRGBO(136, 14, 79, .4),
    400: Color.fromRGBO(136, 14, 79, .5),
    500: Color.fromRGBO(136, 14, 79, .6),
    600: Color.fromRGBO(136, 14, 79, .7),
    700: Color.fromRGBO(136, 14, 79, .8),
    800: Color.fromRGBO(136, 14, 79, .9),
    900: Color.fromRGBO(136, 14, 79, 1),
  };

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Barks(),
        ),
        ChangeNotifierProvider.value(
          value: Songs(),
        ),
        ChangeNotifierProvider.value(
          value: ImageController(),
        ),
        ChangeNotifierProvider.value(
          value: Pictures(),
        ),
        ChangeNotifierProvider.value(
          value: SoundController(),
        ),
        ChangeNotifierProvider.value(
          value: ActiveWaveStreamer(),
        ),
        ChangeNotifierProvider.value(
          value: KaraokeCardDecorationController(),
        ),
        ChangeNotifierProvider.value(
          value: TheUser(),
        ),
        ChangeNotifierProvider.value(
          value: CurrentActivity(),
        ),
        ChangeNotifierProvider.value(
          value: KaraokeCards(),
        ),
        ChangeNotifierProvider.value(
          value: CreatableSongs(),
        ),
        ChangeNotifierProvider.value(
          value: CardAudios(),
        ),
        ChangeNotifierProvider.value(
          value: CardDecorationImages(),
        ),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'K-9 Karaoke',
          theme: ThemeData(
            sliderTheme: SliderThemeData(
              valueIndicatorShape: CustomPaddleSliderValueIndicatorShape(
                sizeMultiplier: 2,
                textScaleMultiplier: 2,
              ),
            ),
            primarySwatch: MaterialColor(0xff234498, color),
            accentColor: MaterialColor(0xff605a5a, color), // Grey
            highlightColor: MaterialColor(0xff3F944A, color), // Green
            errorColor: MaterialColor(0xff9a2020, color),
            fontFamily: 'Museo',
            buttonTheme: ButtonThemeData(
              minWidth: 200.0,
              height: 50.0,
              textTheme: ButtonTextTheme.primary,
              buttonColor: Colors.amber[200],
            ),
          ),
          home: CheckAuthenticationScreen(),
          routes: {
            SubscriptionScreen.routeName: (ctx) => SubscriptionScreen(),
            AboutScreen.routeName: (ctx) => AboutScreen(),
            PrivacyPolicyScreen.routeName: (ctx) => PrivacyPolicyScreen(),
            TermsOfUseScreen.routeName: (ctx) => TermsOfUseScreen(),
            AccountScreen.routeName: (ctx) => AccountScreen(),
            MainScreen.routeName: (ctx) => MainScreen(),
            MenuScreen.routeName: (ctx) => MenuScreen(),
            PhotoLibraryScreen.routeName: (ctx) => PhotoLibraryScreen(),
            CameraOrUploadScreen.routeName: (ctx) => CameraOrUploadScreen(),
            MyCardsScreen.routeName: (ctx) => MyCardsScreen(),
            RetrieveDataScreen.routeName: (ctx) => RetrieveDataScreen(),
            AuthenticationScreen.routeName: (ctx) => AuthenticationScreen(),
            SupportScreen.routeName: (ctx) => SupportScreen(),
            EnvelopeScreen.routeName: (ctx) => EnvelopeScreen(),
          }),
    );
  }
}
