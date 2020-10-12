
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ffmpeg/log_level.dart';

class FFMpeg {
  static final FlutterFFmpegConfig config = FlutterFFmpegConfig();
  static final FlutterFFmpeg process = FlutterFFmpeg();
  static final FlutterFFprobe probe = FlutterFFprobe();

  static final logLevel = config.setLogLevel(LogLevel.AV_LOG_QUIET);
}
