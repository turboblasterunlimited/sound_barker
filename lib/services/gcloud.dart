import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import '../services/http_controller.dart';

class Gcloud {
  static Future<String> _uploadBucketLink(fileName, directory) async {
    final body = {"filename": "$directory/$fileName"};
    final url = 'http://165.227.178.14/signed-upload-url';

    var response;
    try {
      response = await HttpController.dio.post(
        url,
        data: body,
      );
    } catch (e) {
      print("upload bucket link: ${e.message}");
      print(e.response.headers);
      print(e.response.data);
      print(e.response.request);
      print("create decoration image body: ${response.data}");
    }
    return response.data["url"];
    // example response
    // {
    //   "url": "https://storage.googleapis.com/song_barker_sequences/raws/myrawfile.aac?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=song-barker%40songbarker.iam.gserviceaccount.com%2F20200910%2Fauto%2Fstorage%2Fgoog4_request&X-Goog-Date=20200910T193939Z&X-Goog-Expires=901&X-Goog-SignedHeaders=content-type%3Bhost&X-Goog-Signature=63525451b10c3aa6aaf058328d6cbf0ff2cb4b154249e0a18e1b63a72d56394fb928d67b398fdfff4e9c41b0a9ca6c1770958471603b5d162b4c77c9a7d07f7ba13e873c23fae61d3c6303d8e63136d680f6d9cf817e2fd86558cc5eb04dc09eab9058233010dcb02feb0c30636525b5591e5912b906040615b93d81ec79477ce77075f243fbe5553a6b7fb335bd7c931fe5a4ff42a237d7eb68844acbf3bde50a5fa9d66504b16f3ec35249eb7167fa3caf5af0958fec277f8cf1df04c4127658de385bbb72b128e7dcfcaf23b07bc195453222062f3e81e1a2df2eeedae44697a918b1712d1e7c685937e43666df7f5aa311c2874894bdbbc25f3873f84c1c",
    //   "success": true
    // }
  }

  static Future<String> upload(String filePath, String directory) async {
    var fileName = basename(filePath);
    String uploadUrl = await _uploadBucketLink(fileName, directory);
    File file = File(filePath);
    try {
      await HttpController.dio.post(
        uploadUrl,
        data: File(filePath).openRead(), // Post with Stream<List<int>>
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: ContentType.text,
            HttpHeaders.contentLengthHeader: file.lengthSync(),
            // HttpHeaders.authorizationHeader: "Bearer $token",
          },
        ),
      );
    } catch (e) {
      print(e);
    }
    final bucketFp = "$directory/$fileName";
    return bucketFp;
  }

  static Future<String> downloadFromBucket(
      String bucketFp, String filePath) async {
    try {
      Response response = await HttpController.dio.get(
        "https://storage.googleapis.com/song_barker_sequences/$bucketFp",
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            receiveTimeout: 0),
      );
      File file = File(filePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
    } catch (e) {
      print(e);
    }
    return filePath;
  }

  static Future<String> uploadRawBark(fileId, filePath) async {
    String bucketWritePath = "$fileId/raw.aac";

    try {
      // await File(filePath).openRead().pipe(bucket.write(bucketWritePath));
    } catch (e) {
      print(e);
      return e;
    }
    return bucketWritePath;
  }
}
