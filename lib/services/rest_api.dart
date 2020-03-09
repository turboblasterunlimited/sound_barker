import 'package:http/http.dart' as http;
import 'dart:convert';

class RestAPI {
  final Map<String, String> jsonHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };

  Future<String> createSong(cropId, songTitle) async {
    http.Response response;
    String body = json.encode(
        {'uuid': cropId, 'name': songTitle, 'user_id': '999'});
    //print(body);
    final url = 'http://165.227.178.14/sequence_audio';
    try {
      response = await http.post(
        url,
        body: body,
        headers: jsonHeaders,
      );
    } catch (error) {
      //print(error);
      throw error;
    }
    print("create Song on server response body: ${response.body}");
    return response.body;
  }

  Future<String> renameSongOnServer(song, newName) async {
    http.Response response;
    String body = json.encode({'name': newName, "user_id": "999"});
    //print(body);
    final url = 'http://165.227.178.14/sequence/${song.fileId}';
    try {
      response = await http.patch(
        url,
        body: body,
        headers: jsonHeaders,
      );
    } catch (error) {
      print(error);
      throw error;
    }
    print("Edit bark name response body: ${response.body}");
    return response.body;
  }

  Future<String> renameBarkOnServer(bark, newName) async {
    http.Response response;
    String body = json.encode({'name': newName, "user_id": "999"});
    print(body);
    final url = 'http://165.227.178.14/crop/${bark.fileId}';
    try {
      response = await http.patch(
        url,
        body: body,
        headers: jsonHeaders,
      );
    } catch (error) {
      print(error);
      throw error;
    }
    print("Edit bark name response body: ${response.body}");
    return response.body;
  }

  Future<String> retrieveAllSongsFromServer() async {
    http.Response response;
    final url = 'http://165.227.178.14/all/sequence/999';
    try {
      response = await http.get(url);
    } catch (error) {
      print(error);
      throw error;
    }
    print("Get all Songs response body: ${response.body}");
    return response.body;
  }

  Future<String> retrieveAllBarksFromServer() async {
    http.Response response;
    final url = 'http://165.227.178.14/all/crop/999';
    try {
      response = await http.get(url);
    } catch (error) {
      print(error);
      throw error;
    }
    print("Get all Barks response body: ${response.body}");
    return response.body;
  }

  Future<String> deleteSongFromServer(song) async {
        print('checkpoint!');

    http.Response response;
    final url = 'http://165.227.178.14/sequence/${song.fileId}';
    try {
      response = await http.delete(url);
    } catch (error) {
      print("Error: $error");
      throw error;
    }
    print("Song Name: ${song.name}, Song ID: ${song.fileId}");
    print("Delete song response body: ${response.body}");
    return response.body;
  }

  Future<String> deleteBarkFromServer(bark) async {
    http.Response response;
    final url = 'http://165.227.178.14/crop/${bark.fileId}';
    try {
      response = await http.delete(url);
    } catch (error) {
      //print(error);
      throw error;
    }
    print("Delete bark response body: ${response.body}");
    return response.body;
  }

  Future<String> splitRawBarkOnServer(fileId, imageName) async {
    http.Response response;
    String body = json.encode({
      'uuid': fileId,
      'user_id': '999',
      'name': imageName,
    });
    //print(body);
    final url = 'http://165.227.178.14/split_audio';
    try {
      response = await http.post(
        url,
        body: body,
        headers: jsonHeaders,
      );
    } catch (error) {
      //print(error);
      throw error;
    }
    print("split bark server response body content: ${response.body}");
    return response.body;
  }

  Future<void> notifyServerRawBarkInBucket(fileId, imageName) async {
    http.Response response;
    String body = json.encode({
      'user_id': '999',
      'uuid': fileId,
      'name': imageName,
    });
    //print(body);
    // User ID hardcoded as 999 for now.
    final url = 'http://165.227.178.14/raw';
    try {
      response = await http.post(
        url,
        body: body,
        headers: jsonHeaders,
      );
    } catch (error) {
      print(error);
      throw error;
    }
    // print(
    //     "Notify Server Raw Bark in bucket response body content: ${response.body}");
  }
}
