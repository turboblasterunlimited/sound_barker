import 'dart:typed_data';
import 'dart:io';

class AmplitudeExtractor {
  static List<double> extract(String filePath) {
    List<double> result = [];
    // 40 milliseconds == 1/25 frames per second
    // 1764 samples per frame for a 44100 hertz sample rate
    int headerOffset = 44;
    Uint8List bytes = File(filePath).readAsBytesSync();
    int sampleRate = bytes.sublist(24, 28).buffer.asInt32List()[0];
    // framerate = 60
    int sampleChunk = (sampleRate / 60).round();
    List<int> waveSamples =
        bytes.sublist(headerOffset).buffer.asInt16List().toList();

    while (waveSamples.length > sampleChunk) {
      List<int> tempSubList = waveSamples.sublist(0, (sampleChunk - 1));
      // divisor number of samples in a frame of animation Xs the max possible average amplitude
      int divisor = sampleChunk * 10000;
      // amplitude from 0 to 1
      double _amplitude =
          tempSubList.reduce((a, b) => a.abs() + b.abs()) / divisor;
      _amplitude = _amplitude > 1.0 ? 1.0 : _amplitude;
      result.add(_amplitude);
      waveSamples.removeRange(0, (sampleChunk - 1));
    }
    return result;
  }
}
