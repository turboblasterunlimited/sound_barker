import 'dart:typed_data';
import 'dart:io';

class AmplitudeExtractor {
  static List<double> extract(String filePath) {
    print("start extraction");
    List<double> result = [];
    // 40 milliseconds == 1/25 frames per second
    // 1764 samples per frame for a 44100 hertz sample rate
    int headerOffset = 44;
    Uint8List bytes = File(filePath).readAsBytesSync();
    int sampleRate = bytes.sublist(24, 28).buffer.asInt32List()[0];
    int framerate = 60;
    int sampleChunk = (sampleRate / framerate).round();
    List<int> waveSamples =
        bytes.sublist(headerOffset).buffer.asInt16List().toList();
    int waveSamplesLength = waveSamples.length;
    // number of samples in a frame of animation Xs the max possible average amplitude
    int divisor = sampleChunk * 10000;
    List<int> tempSubList;
    double _amplitude;
    int i = 0;
    while ((i + sampleChunk - 1) < waveSamplesLength) {
      tempSubList = waveSamples.sublist(i, (i + sampleChunk - 1));
      // amplitude from 0 to 1
      _amplitude = tempSubList.reduce((a, b) => a.abs() + b.abs()) / divisor;
      result.add(_amplitude > 1.0 ? 1.0 : _amplitude);
      i += (sampleChunk - 1);
    }
    return result;
  }
}
