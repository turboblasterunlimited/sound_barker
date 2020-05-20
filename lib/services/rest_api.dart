import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/http_controller.dart';

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
    String body = json.encode({'uuids': cropIds, 'song_id': songId.toString()});
    print("create song on server req body: $body");
    final url = 'http://165.227.178.14/to_sequence';
    response = await http.post(
      url,
      body: body,
      headers: jsonHeaders,
    );
    print("create Song on server response body: ${response.body}");
    return response.body;
  }

  static Future<String> renameSongOnServer(Song song, String newName) async {
    http.Response response;
    String body = json.encode({'name': newName});
    print(body);
    final url = 'http://165.227.178.14/sequence/${song.fileId}';
    response = await http.patch(
      url,
      body: body,
      headers: jsonHeaders,
    );
    print("Edit bark name response body: ${response.body}");
    return response.body;
  }

  static Future<String> updateImageOnServer(Picture image) async {
    http.Response response;
    String body = json.encode({
      'name': image.name,
      'coordinates_json': image.coordinates,
    });
    print("Image update body: $body");
    final url = 'http://165.227.178.14/image/${image.fileId}';
    response = await http.patch(
      url,
      body: body,
      headers: jsonHeaders,
    );
    print("Edit Image on server response body: ${response.body}");
    return response.body;
  }

  static Future<String> createImageOnServer(Picture image) async {
    http.Response response;
    String body = json.encode({
      'uuid': image.fileId,
      'name': image.name,
      'coordinates_json': image.coordinates,
    });
    print("Image upload body: $body");
    final url = 'http://165.227.178.14/image';
    response = await http.post(
      url,
      body: body,
      headers: jsonHeaders,
    );
    print("create Image on server response body: ${response.body}");
    return response.body;
  }

  static Future<String> renameBarkOnServer(Bark bark, newName) async {
    http.Response response;
    String body = json.encode({'name': newName });
    print(body);
    final url = 'http://165.227.178.14/crop/${bark.fileId}';
    response = await http.patch(
      url,
      body: body,
      headers: jsonHeaders,
    );

    print("Edit bark name response body: ${response.body}");
    return response.body;
  }

  static Future<String> retrieveAllSongsFromServer() async {
    http.Response response;
    final url = 'http://165.227.178.14/all/sequence/dev';
    print(url);
    response = await http.get(url);
    print("Get all Songs response body: ${response.body}");
    return response.body;
  }

  static Future<String> retrieveAllImagesFromServer() async {
    http.Response response;
    final url = 'http://165.227.178.14/all/image/dev';
    print("retrieveAllImages req url: $url");
    response = await http.get(url);
    print("Get all Images response body: ${response.body}");
    return response.body;
  }

  static Future<String> retrieveAllCreatableSongsFromServer() async {
    http.Response response;
    final url = 'http://165.227.178.14/all/song';
    print("retrieveAllCreatableSongs req url: $url");
    response = await http.get(url);
    print("Get all Creatable Songs response body: ${response.body}");
    return response.body;
  }

  static Future<String> retrieveAllBarksFromServer() async {
    http.Response response;
    final url = 'http://165.227.178.14/all/crop/dev';
    print("retrieveAllBarks req url: $url");
    response = await http.get(url);
    print("Get all Barks response body: ${response.body}");
    return response.body;
  }

  static Future<String> deleteImageFromServer(Picture image) async {
    http.Response response;
    final url = 'http://165.227.178.14/image/${image.fileId}';
    print("DeleteImageFromServer req url: $url");
    response = await http.delete(url);
    // print("Song Name: ${image.name}, Song ID: ${song.fileId}");
    print("Delete picture response body: ${response.body}");
    return response.body;
  }

  static Future<String> deleteSongFromServer(Song song) async {
    http.Response response;
    final url = 'http://165.227.178.14/sequence/${song.fileId}';
    print("deleteSongFromServer req url: $url");
    response = await http.delete(url);
    print("Delete song response body: ${response.body}");
    return response.body;
  }

  static Future<String> deleteBarkFromServer(Bark bark) async {
    http.Response response;
    final url = 'http://165.227.178.14/crop/${bark.fileId}';
    print("deleteBarkFromServer req url: $url");
    response = await http.delete(url);
    print("Delete bark response body: ${response.body}");
    return response.body;
  }

  static Future<String> splitRawBarkOnServer(fileId, imageId) async {
    http.Response response;
    String body = json.encode({
      'uuid': fileId,
      'image_id': imageId,
    });
    print("splitRawBark req body $body");
    final url = 'http://165.227.178.14/to_crops';
    response = await http.post(
      url,
      body: body,
      headers: jsonHeaders,
    );
    print("split bark server response body content: ${response.body}");
    return response.body;
  }
}
