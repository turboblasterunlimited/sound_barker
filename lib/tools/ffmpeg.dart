import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/logger.dart';

class FFMpeg {
  static Logger logger = Logger(level: Level.debug);
  static final logLevel = Level.debug;
  static final FlutterSoundFFmpegConfig config =
      FlutterSoundFFmpegConfig(logger);
  //FlutterFFmpegConfig();
  static final FlutterSoundFFmpeg process = FlutterSoundFFmpeg();
  static final FlutterSoundFFprobe probe = FlutterSoundFFprobe();
}
