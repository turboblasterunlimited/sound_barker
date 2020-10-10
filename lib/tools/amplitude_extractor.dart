import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:K9_Karaoke/tools/ffmpeg.dart';

class AmplitudeExtractor {
  static Map<String, dynamic> getSampleData(filePath) {
    int headerOffset = 44;
    Uint8List bytes = File(filePath).readAsBytesSync();
    // 44100
    int sampleRate = bytes.sublist(24, 28).buffer.asInt32List()[0];
    List<int> waveSamples =
        bytes.sublist(headerOffset).buffer.asInt16List().toList();
    int samplesLength = waveSamples.length;
    print("Wave samples length: $samplesLength");
    Map<String, dynamic> result = {
      "samplesLength": samplesLength,
      "waveSamples": waveSamples,
      "sampleRate": sampleRate
    };
    return result;
  }

  static List extract(String filePath) {
    List result = [];
    Map sampleData = getSampleData(filePath);
    int framerate = 60;
    // 735
    int sampleChunk = (sampleData["sampleRate"] / framerate).round();
    // number of samples in a frame of animation Xs the max possible average amplitude
    int divisor = sampleChunk * 10000;
    List<int> tempSubList;
    double _amplitude;
    int i = 0;
    while ((i + sampleChunk - 1) < sampleData["samplesLength"]) {
      tempSubList = sampleData["waveSamples"].sublist(i, (i + sampleChunk - 1));
      // amplitude from 0 to 1 (now 0 to .5 [divisor * 2])
      _amplitude = tempSubList.reduce((a, b) => a.abs() + b.abs()) / divisor;
      // tempSubList.reduce((a, b) => a.abs() + b.abs()) / (divisor * 2);
      result.add(_amplitude > 1 ? 1 : _amplitude);
      i += (sampleChunk - 1);
    }
    // Close the mouth
    result.add(0);
    return result;
  }

  static Future<String> createAmplitudeFile(filePath, [filePathBase]) async {
    filePathBase ??= filePath.substring(0, filePath.length - 4);
    final amplitudes = await getAmplitudes(filePath, filePathBase);
    final csvAmplitudes = const ListToCsvConverter().convert([amplitudes]);
    File file = File("$filePathBase.csv");
    file.writeAsStringSync(csvAmplitudes);
    print("Finish writing amps");
    print(file.path);
    return file.path;
  }

  static Future<List> getAmplitudes(filePath, [filePathBase]) async {
    filePathBase ??= filePath.substring(0, filePath.length - 4);
    if (File("${filePathBase}.wav").existsSync())
      File("${filePathBase}.wav").deleteSync();
    print("filePathBase: $filePathBase");
    print("filePath: $filePath");
    await FFMpeg.process
        .execute("-hide_banner -loglevel panic -i $filePath $filePathBase.wav");
    final amplitudes = extract("$filePathBase.wav");
    File("$filePathBase.wav").deleteSync();
    return amplitudes;
  }

  static Future<List> fileToList(String filePath) async {
    final input = File(filePath).openRead();
    List<List> amplitudes = await input
        .transform(utf8.decoder)
        .transform(CsvToListConverter(shouldParseNumbers: true))
        .toList();
    // print("Amplitudes: $amplitudes");
    return amplitudes[0];
  }
}
