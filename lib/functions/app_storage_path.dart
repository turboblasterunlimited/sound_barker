import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> appStoragePath() async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  return appDocDir.path;
}
