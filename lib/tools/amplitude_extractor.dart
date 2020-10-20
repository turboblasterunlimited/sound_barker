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
    Map<String, dynamic> result = {
      "samplesLength": samplesLength,
      "waveSamples": waveSamples,
      "sampleRate": sampleRate
    };
    return result;
  }

  static List extract(String filePath) {
    print("calling extract");
    Map sampleData = getSampleData(filePath);
    int framerate = 60;
    // 735
    int sampleChunk = (sampleData["sampleRate"] / framerate).round();
    // number of samples in a frame of animation Xs the max possible average amplitude
    int divisor = sampleChunk * 10000;
    List<int> tempSubList;
    double _amplitude;
    int i = 0;
    print("checkpoint");
    double biggestAmplitude = 0;
    List<double> amplitudes =[];
    List<double> normalizedAmplitudes = [];
    while ((i + sampleChunk - 1) < sampleData["samplesLength"]) {
      tempSubList = sampleData["waveSamples"].sublist(i, (i + sampleChunk - 1));
      _amplitude = tempSubList.reduce((a, b) => a.abs() + b.abs()) / divisor;
      biggestAmplitude =
          _amplitude > biggestAmplitude ? _amplitude : biggestAmplitude;
      amplitudes.add(_amplitude);
      i += (sampleChunk - 1);
    }
    print("checkpoint 1");
    // map all amplitudes from 0 - 1.
    normalizedAmplitudes = amplitudes.map((amp) {
      return amp / biggestAmplitude;
    }).toList();

    print("checkpoint 2");
    // Close the mouth
    normalizedAmplitudes.add(0);
    print("Checkpoint 3");
    print("amps result: $normalizedAmplitudes");
    return normalizedAmplitudes;
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
    var result = await FFMpeg.process
        .execute("-hide_banner -loglevel panic -i $filePath $filePathBase.wav");
    print("ffmpeg result: $result");
    final amplitudes = extract("$filePathBase.wav");
    File("$filePathBase.wav").deleteSync();
    return amplitudes;
  }

  static Future<List<double>> fileToList(String filePath) async {
    final input = File(filePath).openRead();
    List<List> amplitudes = await input
        .transform(utf8.decoder)
        .transform(CsvToListConverter(shouldParseNumbers: true))
        .toList();
    // print("Amplitudes: $amplitudes");
    List<double> result = amplitudes[0].cast<double>();
    return result;
  }
}
