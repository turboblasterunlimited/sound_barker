import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:K9_Karaoke/tools/ffmpeg.dart';

class AmplitudeExtractor {
  static List<double> extract(String filePath) {
    print("start extraction");
    List<double> result = [];
    int headerOffset = 44;
    Uint8List bytes = File(filePath).readAsBytesSync();
    // 44100
    int sampleRate = bytes.sublist(24, 28).buffer.asInt32List()[0];
    int framerate = 60;
    // 735
    int sampleChunk = (sampleRate / framerate).round();
    List<int> waveSamples =
        bytes.sublist(headerOffset).buffer.asInt16List().toList();
    int waveSamplesLength = waveSamples.length;
    print("Wave samples length: $waveSamplesLength");
    // number of samples in a frame of animation Xs the max possible average amplitude
    int divisor = sampleChunk * 10000;
    List<int> tempSubList;
    double _amplitude;
    int i = 0;
    while ((i + sampleChunk - 1) < waveSamplesLength) {
      tempSubList = waveSamples.sublist(i, (i + sampleChunk - 1));
      // amplitude from 0 to 1 (now 0 to .5 [divisor * 2])
      _amplitude =
          tempSubList.reduce((a, b) => a.abs() + b.abs()) / (divisor * 2);
      result.add(_amplitude > 0.5 ? 0.5 : _amplitude);
      i += (sampleChunk - 1);
    }
    // Close the mouth
    result.add(0);
    return result;
  }

  static Future<String> createAmplitudeFile(filePath, [filePathBase]) async {
    final amplitudes = await getAmplitudes(filePath, filePathBase);
    final csvAmplitudes = const ListToCsvConverter().convert([amplitudes]);
    File file = File("$filePathBase.csv");
    file.writeAsStringSync(csvAmplitudes);
    return file.path;
  }

  static Future<List> getAmplitudes(filePath, [filePathBase]) async {
    filePathBase ??= filePath.substring(0, filePath.length - 4);
    await FFMpeg.process
        .execute("-hide_banner -loglevel panic -i $filePath $filePathBase.wav");
    final amplitudes = extract("$filePathBase.wav");
    File("$filePathBase.wav").deleteSync();
    return amplitudes;
  }

  static Future<List> fileToList(filePath) async {
    final input = File(filePath).openRead();
    List amplitudes = await input
        .transform(utf8.decoder)
        .transform(CsvToListConverter())
        .toList();
    return amplitudes;
  }
}
