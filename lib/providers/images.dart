import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';

import '../services/gcloud.dart';
import '../services/rest_api.dart';

class Images with ChangeNotifier, Gcloud {
  List<Image> all = [];

}

class Image with ChangeNotifier {
  
}