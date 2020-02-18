import 'package:flutter/foundation.dart';

import '../services/gcloud.dart';

class Songs {

}
class Song with ChangeNotifier, Gcloud{
  String name;
  String fileUrl;
  String filePath;
  String id;

  Song({this.filePath, this.name});

 
  void playSong() {}

}
