import 'package:http/http.dart' as http;
import 'dart:convert';

class RestAPI {
  static final Map<String, String> jsonHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<String> createSong(cropIds, songId) async {
    http.Response response;
    String body =
        json.encode({'uuids': cropIds, 'user_id': 'dev', 'song_id': songId.toString()});
        print("create song on server req body: $body");

    final url = 'http://165.227.178.14/to_sequence';
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
    String body = json.encode({'name': newName, "user_id": "dev"});
    //print(body);
    final url = 'http://165.227.178.14/sequence/${song.fileId}';
    try {
      response = await http.patch(
        url,
        body: body,
        headers: jsonHeaders,
      );
    } catch (error) {
      // print(error);
      throw error;
    }
    // print("Edit bark name response body: ${response.body}");
    return response.body;
  }

    Future<String> updateImageOnServer(image) async {
    http.Response response;
    String body = json.encode({
      'name': image.name,
      'coordinates': image.coordinates,
    });
    // print("Image update body: $body");
    final url = 'http://165.227.178.14/image/${image.fileId}';
    try {
      response = await http.patch(
        url,
        body: body,
        headers: jsonHeaders,
      );
    } catch (error) {
      //print(error);
      throw error;
    }
    // print("Edit Image on server response body: ${response.body}");
    return response.body;
  }

  Future<String> createImageOnServer(image) async {
    http.Response response;
    String body = json.encode({
      'uuid': image.fileId,
      'name': image.name,
      'user_id': 'dev',
      'coordinates': image.coordinates,
    });
    // print("Image upload body: $body");
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
    // print("create Image on server response body: ${response.body}");
    return response.body;
  }

  Future<String> renameBarkOnServer(bark, newName) async {
    http.Response response;
    String body = json.encode({'name': newName, "user_id": "dev"});
    // print(body);
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
    // print("Edit bark name response body: ${response.body}");
    return response.body;
  }

  Future<String> retrieveAllSongsFromServer() async {
    http.Response response;
    final url = 'http://165.227.178.14/all/sequence/dev';
    try {
      response = await http.get(url);
    } catch (error) {
      print(error);
      throw error;
    }
    // print("Get all Songs response body: ${response.body}");
    return response.body;
  }

  Future<String> retrieveAllImagesFromServer() async {
    http.Response response;
    final url = 'http://165.227.178.14/all/image/dev';
    try {
      response = await http.get(url);
    } catch (error) {
      print(error);
      throw error;
    }
    // print("Get all Images response body: ${response.body}");
    return response.body;
  }

  static Future<String> retrieveAllCreatableSongsFromServer() async {
    http.Response response;
    final url = 'http://165.227.178.14/all/song';
    try {
      response = await http.get(url);
    } catch (error) {
      print(error);
      throw error;
    }
    // print("Get all Creatable Songs response body: ${response.body}");
    return response.body;
  }

  Future<String> retrieveAllBarksFromServer() async {
    http.Response response;
    final url = 'http://165.227.178.14/all/crop/dev';
    try {
      response = await http.get(url);
    } catch (error) {
      print(error);
      throw error;
    }
    // print("Get all Barks response body: ${response.body}");
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
    // print("Delete picture response body: ${response.body}");
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
    // print("Song Name: ${song.name}, Song ID: ${song.fileId}");
    // print("Delete song response body: ${response.body}");
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
    // print("Delete bark response body: ${response.body}");
    return response.body;
  }

  Future<String> splitRawBarkOnServer(fileId, imageId) async {
    http.Response response;
    String body = json.encode({
      'uuid': fileId,
      'user_id': 'dev',
      'image_id': imageId,
    });
    // print(body);
    final url = 'http://165.227.178.14/to_crops';
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
    // print("split bark server response body content: ${response.body}");
    return response.body;
  }
}
