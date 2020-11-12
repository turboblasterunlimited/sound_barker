import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:K9_Karaoke/tools/ffmpeg.dart';
import 'package:path_provider/path_provider.dart';

class AmplitudeExtractor {
  // static final queue = Queue();
  // static final streamController = StreamController<String>();
  // static processStreamer() {
  //   queue.
  // }

  static void _printWavFileHeader(bytes) {
    var subChunk1Size = bytes.sublist(16, 22).buffer.asInt32List().toList();
    print("subChunk1Size: $subChunk1Size");
    var audioFormat = bytes.sublist(20, 22).buffer.asInt16List().toList();
    print("audioFormat: $audioFormat");
    var numOfChannels = bytes.sublist(22, 24).buffer.asInt16List().toList();
    print("numOfChannels: $numOfChannels");
    var byteRate = bytes.sublist(28, 32).buffer.asInt32List();
    print("byteRate: $byteRate");
    var blockAlign = bytes.sublist(32, 34).buffer.asInt16List();
    print("blockAlign: $blockAlign");
    var bitsPerSample = bytes.sublist(34, 36).buffer.asInt16List();
    print("bitsPerSample: $bitsPerSample");
    var subChunkSize = bytes.sublist(36, 40).buffer.asInt32List();
    print("subChunkSize: $subChunkSize");
  }

  static Map<String, dynamic> getSampleData(filePath) {
    int headerOffset = 44;
    Uint8List bytes = File(filePath).readAsBytesSync();

    // _printWavFileHeader(bytes);

    // Just need sample rate, should be: 44100
    var sampleRate = bytes.sublist(24, 28).buffer.asInt32List().toList()[0];
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
    Map sampleData = getSampleData(filePath);
    int framerate = 60;
    // 735
    int sampleChunk = (sampleData["sampleRate"] / framerate).round();
    List<int> tempSubList;
    double _amplitude;
    int i = 0;
    double biggestAmplitude = 0;
    List<double> amplitudes = [];
    List<double> normalizedAmplitudes = [];
    while ((i + sampleChunk - 1) < sampleData["samplesLength"]) {
      tempSubList = sampleData["waveSamples"].sublist(i, (i + sampleChunk - 1));
      _amplitude = tempSubList.reduce((a, b) => a.abs() + b.abs()).toDouble();
      biggestAmplitude =
          _amplitude > biggestAmplitude ? _amplitude : biggestAmplitude;
      amplitudes.add(_amplitude);
      i += (sampleChunk - 1);
    }
    // map all amplitudes from 0 - 1.
    normalizedAmplitudes = amplitudes.map((amp) {
      return amp / biggestAmplitude;
    }).toList();
    // Close the mouth
    normalizedAmplitudes.add(0);
    return normalizedAmplitudes;
  }

  // static Future<String> queueAmplitudeFile(filePath, [filePathBase]) {
  //   queue.add([filePath, filePathBase]);
  //   Stream()
  // }



  static Future<String> createAmplitudeFile(filePath, [filePathBase]) async {
    filePathBase ??= filePath.substring(0, filePath.length - 4);
    final amplitudes = await getAmplitudes(filePath, filePathBase);
    final csvAmplitudes = const ListToCsvConverter().convert([amplitudes]);
    File file = File("$filePathBase.csv");
    file.writeAsStringSync(csvAmplitudes);
    return file.path;
  }

  static Future<List> getAmplitudes(filePath, [filePathBase]) async {
    filePathBase ??= filePath.substring(0, filePath.length - 4);
    if (File("${filePathBase}.wav").existsSync())
      File("${filePathBase}.wav").deleteSync();
    await FFMpeg.process
        .execute("-hide_banner -loglevel panic -i $filePath -ac 1 $filePathBase.wav");

    // ONLY ANDROID:
    // _createAccessibleWavFile(filePathBase);

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
    List<double> result = amplitudes[0].cast<double>();
    return result;
  }

  // ONLY ANDROID:
  // static Future<void> _createAccessibleWavFile(filePathBase) async {
  //   List<Directory> musicFolder =
  //       await getExternalStorageDirectories(type: StorageDirectory.music);
  //   String musicFolderPath = musicFolder[0].path;
  //   if (File("$musicFolderPath/testtest.wav").existsSync())
  //     File("$musicFolderPath/testtest.wav").deleteSync();
  //   File("$musicFolderPath/testtest.wav").createSync();
  //   File("$filePathBase.wav").copySync("$musicFolderPath/testtest.wav");
  //   print("created file at: $musicFolderPath/testtest.wav");
  // }
}
