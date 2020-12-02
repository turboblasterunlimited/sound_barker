import 'dart:io';
import 'package:K9_Karaoke/globals.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import '../services/http_controller.dart';

class Gcloud {
  static Future<String> _uploadBucketLink(
      String fileName, String directory, String contentType) async {
    final body = {
      "filepath": "$directory/$fileName",
      "content_type": contentType,
    };
    final url = 'https://$serverURL/signed-upload-url';

    print("upload bucket link body: $body");
    var response;
    try {
      response = await HttpController.dioPost(
        url,
        data: body,
      );
    } catch (e) {
      throw (e);
    }
    print("upload bucket link response: $response");
    return response.data["url"];
    // example response
    // {
    //   "url": "https://storage.googleapis.com/song_barker_sequences/raws/myrawfile.aac?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=song-barker%40songbarker.iam.gserviceaccount.com%2F20200910%2Fauto%2Fstorage%2Fgoog4_request&X-Goog-Date=20200910T193939Z&X-Goog-Expires=901&X-Goog-SignedHeaders=content-type%3Bhost&X-Goog-Signature=63525451b10c3aa6aaf058328d6cbf0ff2cb4b154249e0a18e1b63a72d56394fb928d67b398fdfff4e9c41b0a9ca6c1770958471603b5d162b4c77c9a7d07f7ba13e873c23fae61d3c6303d8e63136d680f6d9cf817e2fd86558cc5eb04dc09eab9058233010dcb02feb0c30636525b5591e5912b906040615b93d81ec79477ce77075f243fbe5553a6b7fb335bd7c931fe5a4ff42a237d7eb68844acbf3bde50a5fa9d66504b16f3ec35249eb7167fa3caf5af0958fec277f8cf1df04c4127658de385bbb72b128e7dcfcaf23b07bc195453222062f3e81e1a2df2eeedae44697a918b1712d1e7c685937e43666df7f5aa311c2874894bdbbc25f3873f84c1c",
    //   "success": true
    // }
  }

  static Future<String> uploadRawBark(fileId, filePath) async {
    String bucketWritePath = "$fileId/raw.aac";
    return await upload(bucketWritePath, fileId, filePath);
  }

  static Future<String> upload(String filePath, String directory,
      [String clientFilePath]) async {
    var fileName = basename(filePath);
    final contentType =
        fileName.split(".")[1] == 'aac' ? 'audio/mpeg' : 'image/jpeg';
    var response;
    try {
      String uploadUrl =
          await _uploadBucketLink(fileName, directory, contentType);
      File file = File(clientFilePath ?? filePath);
      response = await HttpController.dio.put(
        uploadUrl,
        data: Stream.fromIterable(file.readAsBytesSync().map((e) => [e])),
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: contentType,
          },
        ),
      );
    } catch (e) {
      print("Upload Error: $e");
      throw(e);
    }
    print("upload response: $response");
    final bucketFp = "$directory/$fileName";
    return bucketFp;
  }

  static Future<String> downloadFromBucket(
      String bucketFp, String filePath) async {
    print("Downloading!!! $filePath");
    Response response;
    try {
      response = await HttpController.dioGet(
        "https://storage.googleapis.com/$bucketName/$bucketFp",
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
      print("Google Cloud bucket download error: $e");
      print("response: $response");
      print("bucket name: $bucketName");
      print("bucket fp: $bucketFp");
    }
    return filePath;
  }
}
