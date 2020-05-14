import 'dart:io';
import 'package:csv/csv.dart';
import 'package:song_barker/services/amplitude_extractor.dart';
import 'package:song_barker/services/ffmpeg.dart';

Future<String> createAmplitudeFile(filePath, [filePathBase]) async {
  filePathBase ??= filePath.substring(0, filePath.length - 4);
  await FFMpeg.converter
      .execute("-hide_banner -loglevel panic -i $filePath $filePathBase.wav");
  print("filePathBase.wav exists: ${File('$filePathBase.wav').existsSync()}");
  final amplitudes = AmplitudeExtractor.extract("$filePathBase.wav");
  final csvAmplitudes = const ListToCsvConverter().convert([amplitudes]);
  File file = File("$filePathBase.csv");
  await File("$filePathBase.wav").delete();
  file.writeAsStringSync(csvAmplitudes);
  return file.path;
}
