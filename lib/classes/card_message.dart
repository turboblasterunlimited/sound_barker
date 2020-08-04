import 'dart:io';

class CardMessage {
  String filePath;
  String alteredFilePath;
  List amplitudes;
  List alteredAmplitudes;
  Function notifyCardChanges;
  CardMessage({
    this.filePath = "",
    this.alteredFilePath = "",
    this.amplitudes,
    this.alteredAmplitudes,
  });

  bool get exists {
    return amps != null && path != null;
  }

  String get path {
    if (File(alteredFilePath).existsSync())
      return alteredFilePath;
    else if (File(filePath).existsSync())
      return filePath;
    else
      return null;
  }

  List get amps {
    if (alteredAmplitudes != null)
      return alteredAmplitudes;
    else if (amplitudes != null)
      return amplitudes;
    else
      return null;
  }

  void setFilePath(newFilePath) {
    filePath = newFilePath;
    notifyCardChanges();
  }

  void deleteEverything() {
    if (File(filePath).existsSync()) File(filePath).deleteSync();
    amplitudes = null;
    if (File(alteredFilePath).existsSync()) File(alteredFilePath).deleteSync();
    alteredAmplitudes = null;
    // notifyCardChanges();
  }

  void deleteAlteredFiles() {
    if (File(alteredFilePath).existsSync()) File(alteredFilePath).deleteSync();
    alteredAmplitudes = null;
  }
}