import 'dart:io';
import 'package:csv/csv.dart';
import 'package:song_barker/services/amplitude_extractor.dart';
import 'package:song_barker/services/ffmpeg.dart';

createAmplitudeFile(filePath, [filePathBase]) async {
  filePathBase ??= filePath.substring(0, filePath.length - 4);
  await FFMpeg.converter
      .execute("-hide_banner -loglevel panic -i $filePath $filePathBase.wav");
  final amplitudes = AmplitudeExtractor.extract("$filePathBase.wav");
  File("$filePathBase.wav").delete();
  final csvAmplitudes = const ListToCsvConverter().convert([amplitudes]);
  File file = File("$filePathBase.csv");
  file.writeAsStringSync(csvAmplitudes);
  return file.path;
}
