import 'dart:io';
import 'package:path_provider/path_provider.dart';

String myAppStoragePath;
//  JUST RUN ONCE in main.dart AND USE myAppStoragePath afterwards.
Future<String> appStoragePath() async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  myAppStoragePath = appDocDir.path;
  return appDocDir.path;
}
