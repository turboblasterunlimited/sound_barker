import 'dart:io';

class CardMessage {
  String filePath;
  String alteredFilePath;
  String ampFilePath;
  String alteredAmpFilePath;
  CardMessage({
    this.filePath,
    this.alteredFilePath,
    this.ampFilePath,
    this.alteredAmpFilePath,
  });

  String get path {
    if (File(alteredFilePath).existsSync()) {
      return alteredFilePath;
    } else {
      return filePath;
    }
  }

  void deleteEverything() {
    if (File(filePath).existsSync()) File(filePath).deleteSync();
    if (File(ampFilePath).existsSync()) File(ampFilePath).deleteSync();
    if (File(alteredFilePath).existsSync()) File(alteredFilePath).deleteSync();
    if (File(alteredAmpFilePath).existsSync())
      File(alteredAmpFilePath).deleteSync();
  }

  void deleteAlteredFiles() {
    if (File(alteredFilePath).existsSync()) File(alteredFilePath).deleteSync();
    if (File(alteredAmpFilePath).existsSync())
      File(alteredAmpFilePath).deleteSync();
  }
}
