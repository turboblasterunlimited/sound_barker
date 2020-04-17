import 'package:http/http.dart' as http;
import 'dart:convert';

import '../providers/songs.dart';
import '../providers/barks.dart';
import '../providers/pictures.dart';



class RestAPI {
  static final Map<String, String> jsonHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<String> createSong(cropIds, songId) async {
    http.Response response;

    /// "Song" on the server side means "creatable song"
    String body = json.encode(
        {'uuids': cropIds, 'user_id': 'dev', 'song_id': songId.toString()});
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

  static Future<String> renameSongOnServer(Song song, String newName) async {
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

  static Future<String> updateImageOnServer(Picture image) async {
    http.Response response;
    String body = json.encode({
      'name': image.name,
      'coordinates_json': image.coordinates,
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

  static Future<String> createImageOnServer(Picture image) async {
    http.Response response;
    String body = json.encode({
      'uuid': image.fileId,
      'name': image.name,
      'user_id': 'dev',
      'coordinates_json': image.coordinates,
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

  static Future<String> renameBarkOnServer(Bark bark, newName) async {
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

  static Future<String> retrieveAllSongsFromServer() async {
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

  static Future<String> retrieveAllImagesFromServer() async {
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

  static Future<String> retrieveAllBarksFromServer() async {
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

  static Future<String> deleteImageFromServer(Picture image) async {
    http.Response response;
    final url = 'http://165.227.178.14/image/${image.fileId}';
    print(url);
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

  static Future<String> deleteSongFromServer(Song song) async {
    http.Response response;
    final url = 'http://165.227.178.14/sequence/${song.fileId}';
    // print(url);
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

  static Future<String> deleteBarkFromServer(Bark bark) async {
    http.Response response;
    final url = 'http://165.227.178.14/crop/${bark.fileId}';
    print("BARK filePath: ${bark.filePath}");
    print("BARK created: ${bark.created}");
    print("Bark url: ${bark.fileUrl}");

    print(url);
    try {
      response = await http.delete(url);
    } catch (error) {
      //print(error);
      throw error;
    }
    print("Delete bark response body: ${response.body}");
    return response.body;
  }

  static Future<String> splitRawBarkOnServer(fileId, imageId) async {
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
    print("split bark server response body content: ${response.body}");
    return response.body;
  }
}
