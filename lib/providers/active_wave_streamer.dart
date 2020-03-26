import 'dart:async';
import 'package:flutter/material.dart';

class ActiveWaveStreamer with ChangeNotifier {
  StreamSubscription<double> waveStreamer;
}
