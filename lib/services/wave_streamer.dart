import 'dart:typed_data';
import 'dart:io';
import 'dart:async';

// int headerOffset = 44;
// File sample = await File("${Directory.current.path}/lib/assets/sample.wav");

// Uint8List bytes = File(sample.path).readAsBytesSync();

// String fileType = String.fromCharCodes(bytes.sublist(0, 4));
// int fileSize = bytes.sublist(4, 8).buffer.asInt32List()[0];
// String fileTypeHeader = String.fromCharCodes(bytes.sublist(8, 12));
// String formatChunkMarker = String.fromCharCodes(bytes.sublist(12, 16));
// int formatDataLength = bytes.sublist(16, 20).buffer.asInt32List()[0];
// int typeOfFormat = bytes.sublist(20, 22).buffer.asInt16List()[0];
// int numberOfChannels = bytes.sublist(22, 24).buffer.asInt16List()[0];
// int sampleRate = bytes.sublist(24, 28).buffer.asInt32List()[0];
// int sampleRateByBitsPerSampleByChannels =
//     bytes.sublist(28, 32).buffer.asInt32List()[0];
// int bitsPerSampleByChannels = bytes.sublist(32, 34).buffer.asInt16List()[0];
// int bitsPerSample = bytes.sublist(34, 36).buffer.asInt16List()[0];
// int dataChunkHeader = bytes.sublist(36, 40).buffer.asInt16List()[0];
// int sizeOfDataSection = bytes.sublist(40, 44).buffer.asInt32List()[0];

// print("File type: $fileType");
// print("File size: $fileSize");
// print("File type header: $fileTypeHeader");
// print("Format chunk marker: $formatChunkMarker");
// print("Format data length: $formatDataLength");
// print("Type of format: $typeOfFormat");
// print("Number of channels: $numberOfChannels");
// print("Sample rate: $sampleRate");
// print(
//     "Sample rate * bits/sample * sample/channels: $sampleRateByBitsPerSampleByChannels");
// print("Bits/sample * sample/channels: $bitsPerSampleByChannels");
// print("Data chunk header: $dataChunkHeader");
// print("Size of data section: $sizeOfDataSection");

//   Positions   Sample Value         Description
// 1 - 4       "RIFF"               Marks the file as a riff file. Characters are each 1. byte long.
// 5 - 8       File size (integer)  Size of the overall file - 8 bytes, in bytes (32-bit integer). Typically, you'd fill this in after creation.
// 9 -12       "WAVE"               File Type Header. For our purposes, it always equals "WAVE".
// 13-16       "fmt "               Format chunk marker. Includes trailing null
// 17-20       16                   Length of format data as listed above
// 21-22       1                    Type of format (1 is PCM) - 2 byte integer
// 23-24       2                    Number of Channels - 2 byte integer
// 25-28       44100                Sample Rate - 32 bit integer. Common values are 44100 (CD), 48000 (DAT). Sample Rate = Number of Samples per second, or Hertz.
// 29-32       176400               (Sample Rate * BitsPerSample * Channels) / 8.
// 33-34       4                    (BitsPerSample * Channels) / 8.1 - 8 bit mono2 - 8 bit stereo/16 bit mono4 - 16 bit stereo
// 35-36       16                   Bits per sample
// 37-40       "data"               "data" chunk header. Marks the beginning of the data section.
// 41-44       File size (data)     Size of the data section, i.e. file size - 44 bytes header.

// String header = bytes;
// Int16List soundData = bytes.sublist(headerOffset).buffer.asInt16List();
// print("Number of samples: ${soundData.length}");

StreamSubscription<double> performAudio(path, imageController) {
  if (File(path).exists() == null) {
    return null;
  }
  Stream<double> waveStreamer;
  StreamSubscription<double> subscription;
  try {
    imageController.setMouth(0);
    waveStreamer = WaveStreamer(path).stream;
    subscription = waveStreamer.listen((_amplitude) {
      print('Frame amplitude: $_amplitude');
      imageController.setMouth(_amplitude);
    }, onError: (e) {
      print(e);
    }, onDone: () {
      imageController.setMouth(0);
    });
  } catch (e) {
    print("Error: $e");
  }
  return subscription;
}

class WaveStreamer {
  // 40 milliseconds == 1/25 frames per second
  // 1764 samples per frame for a 44100 hertz sample rate
  WaveStreamer(String filePath) {
    int headerOffset = 44;

    Uint8List bytes = File(filePath).readAsBytesSync();
    Int16List samples = bytes.sublist(headerOffset).buffer.asInt16List();
    List<int> waveSamples = samples.toList();
    double _amplitude;
    List<int> tempSubList;
    Timer.periodic(Duration(milliseconds: 110), (t) {
      if (waveSamples.length < 1764) {
        _controller.close();
        return;
      }
      tempSubList = waveSamples.sublist(0, 1763);
      // divisor number of samples in a frame of animation Xs the max possible average amplitude
      int divisor = 1764 * 10000;
      // amplitude from 0 to 1
      _amplitude = tempSubList.reduce((a, b) => a.abs() + b.abs()) / divisor;
      _controller.sink.add(_amplitude);
      waveSamples.removeRange(0, 1763);
    });
  }

  final _controller = StreamController<double>();

  Stream<double> get stream => _controller.stream;
}
