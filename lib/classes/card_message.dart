import 'dart:io';

class CardMessage {
  String filePath;
  String alteredFilePath;
  List amplitudes;
  List alteredAmplitudes;
  CardMessage({
    this.filePath = "",
    this.alteredFilePath = "",
    this.amplitudes,
    this.alteredAmplitudes,
  });

  bool get exists {
    return path != null;
  }

  String get path {
    if (File(alteredFilePath).existsSync())
      return alteredFilePath;
    else if (File(alteredFilePath).existsSync())
      return filePath;
    else
      return null;
  }

  List get ampsPath {
    if (amplitudes != null)
      return amplitudes;
    else
      return alteredAmplitudes;
  }

  void deleteEverything() {
    if (File(filePath).existsSync()) File(filePath).deleteSync();
    amplitudes = null;
    if (File(alteredFilePath).existsSync()) File(alteredFilePath).deleteSync();
    alteredAmplitudes = null;
  }

  void deleteAlteredFiles() {
    if (File(alteredFilePath).existsSync()) File(alteredFilePath).deleteSync();
    alteredAmplitudes = null;
  }
}
