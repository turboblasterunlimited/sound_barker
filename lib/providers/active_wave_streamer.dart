import 'dart:async';
import 'package:flutter/material.dart';

class ActiveWaveStreamer with ChangeNotifier {
  // ignore: cancel_subscriptions
  late StreamSubscription<double> waveStreamer;
}
