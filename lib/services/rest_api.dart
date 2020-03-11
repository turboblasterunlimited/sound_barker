import 'package:http/http.dart' as http;
import 'dart:convert';

class RestAPI {
  final Map<String, String> jsonHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };

  Future<String> createSong(cropId, songId) async {
    http.Response response;
    String body =
        json.encode({'uuid': cropId, 'user_id': '999', 'song_id': songId});
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

  Future<String> createImageOnServer(image) async {
    // ADD MOUTH COORDINATES WHEN READY!
    http.Response response;
    String body = json
        .encode({'uuid': image.fileId, 'name': image.name, 'user_id': '999'});
    //print(body);
    final url = 'http://165.227.178.14/image';
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
    print("create Image on server response body: ${response.body}");
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

  Future<String> retrieveAllImagesFromServer() async {
    http.Response response;
    final url = 'http://165.227.178.14/all/image/999';
    try {
      response = await http.get(url);
    } catch (error) {
      print(error);
      throw error;
    }
    print("Get all Images response body: ${response.body}");
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

  Future<String> deleteImageFromServer(image) async {
    http.Response response;
    final url = 'http://165.227.178.14/image/${image.fileId}';
    try {
      response = await http.delete(url);
    } catch (error) {
      print("Error: $error");
      throw error;
    }
    // print("Song Name: ${image.name}, Song ID: ${song.fileId}");
    print("Delete picture response body: ${response.body}");
    return response.body;
  }

  Future<String> deleteSongFromServer(song) async {

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

  Future<String> splitRawBarkOnServer(fileId, imageId) async {
    http.Response response;
    String body = json.encode({
      'uuid': fileId,
      'user_id': '999',
      'image_id': imageId,
    });
    print(body);
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
}
