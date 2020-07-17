import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../services/http_controller.dart';
import '../providers/songs.dart';
import '../providers/barks.dart';
import '../providers/pictures.dart';

class RestAPI {

  static Future<String> logoutUser(email) async {
    print("logging out...");
    var response;
    try {
      response = await HttpController.dio.post(
        "http://165.227.178.14/logout"
      );
    } catch (e) {
      return e.message;
    }
    print("logout response body: ${response.data}");
    return response.data;
  }

  static Future<String> createCardOnServer(
      String decorationImageId, String audioId, amplitudes, String imageId) async {
    String cardId = Uuid().v4();
    // create card decoration image
    final imageBody = {'uuid': decorationImageId};
    final imageUrl = 'http://165.227.178.14/decoration_image';

    var response;
    try {
      response = await HttpController.dio.post(
        imageUrl,
        data: imageBody,
      );
    } catch (e) {
      print("create decoration image: ${e.message}");
      print(e.response.headers);
      print(e.response.data);
      print(e.response.request);
    }
    print("create decoration image body: ${response.data}");

    // create card audio
    final audioBody = {'uuid': audioId};
    final audioUrl = 'http://165.227.178.14/card_audio';

    try {
      response = await HttpController.dio.post(
        audioUrl,
        data: audioBody,
      );
    } catch (e) {
      print("create card audio error: ${e.message}");
      print(e.response.headers);
      print(e.response.data);
      print(e.response.request);
    }
    print("create card audio body: ${response.data}");

    final cardBody = {
      'uuid': cardId,
      'card_audio_id': audioId,
      "image_id": imageId,
      'decoration_image_id': decorationImageId,
      'animation_json': '{"mouth_positions": $amplitudes}'
    };
    final cardUrl = 'http://165.227.178.14/greeting_card';
    print("card request body: $cardBody");
    try {
      response = await HttpController.dio.post(
        cardUrl,
        data: cardBody,
      );
    } catch (e) {
      print("create greeting card error: ${e.message}");
      print(e.response.headers);
      print(e.response.data);
      print(e.response.request);
    }
    print("create greeting card body: ${response.data}");
    return response.data.toString();
  }

  static Future<Map> createSong(cropIds, songId) async {
    /// "Song" on the server side means "creatable song"
    Map body = {'uuids': cropIds, 'song_id': songId.toString()};
    print("create song on server req body: $body");
    final url = 'http://165.227.178.14/to_sequence';
    var response;
    try {
      response = await HttpController.dio.post(
        url,
        data: body,
      );
    } catch (e) {
      print("Split RAw bark error message: ${e.message}");
      print(e.response.headers);
      print(e.response.data);
      print(e.response.request);
    }
    print("create Song on server response body: ${response.data}");
    return response.data;
  }

  static Future<void> renameSongOnServer(Song song, String newName) async {
    Map body = {'name': newName};
    print(body);
    final url = 'http://165.227.178.14/sequence/${song.fileId}';
    final response = await HttpController.dio.patch(
      url,
      data: body,
    );
    print("Edit bark name response body: ${response.data}");
  }

  static Future<void> updateImageOnServer(Picture image) async {
    Map body = {
      'name': image.name,
      'coordinates_json': json.encode(image.coordinates),
      'mouth_color': image.mouthColor,
    };
    print("Image update body: $body");
    final url = 'http://165.227.178.14/image/${image.fileId}';
    final response = await HttpController.dio.patch(
      url,
      data: body,
    );
    print("Edit Image on server response body: ${response.data}");
  }

  static Future<Map> createImageOnServer(Picture image) async {
    Map body = {
      'uuid': image.fileId,
      'name': image.name,
      'coordinates_json': json.encode(image.coordinates),
      'mouth_color': image.mouthColor,
      'bucket_fp': image.fileUrl
    };
    print("Image upload body: $body");
    final url = 'http://165.227.178.14/image';
    final response = await HttpController.dio.post(
      url,
      data: body,
    );
    print("create Image on server response body: ${response.data}");
    return response.data;
  }

  static void renameBarkOnServer(Bark bark, newName) async {
    Map body = {'name': newName};
    print(body);
    final url = 'http://165.227.178.14/crop/${bark.fileId}';
    final response = await HttpController.dio.patch(
      url,
      data: body,
    );
    print("Edit bark name response body: ${response.data}");
  }

  static Future<List> retrieveAllSongsFromServer() async {
    final url = 'http://165.227.178.14/all/sequence';
    print(url);
    final response = await HttpController.dio.get(url);
    print("Get all Songs response body: ${response.data}");
    return response.data;
  }

  static Future<List> retrieveAllImagesFromServer() async {
    final url = 'http://165.227.178.14/all/image';
    print("retrieveAllImages req url: $url");
    final response = await HttpController.dio.get(url);
    print("Get all Images response body: ${response.data}");
    return response.data;
  }

  static Future<List> retrieveAllCreatableSongsFromServer() async {
    final url = 'http://165.227.178.14/all/song';
    print("retrieveAllCreatableSongs req url: $url");
    final response = await HttpController.dio.get(url);
    print("Get all Creatable Songs response body: ${response.data}");
    return response.data;
  }

  static Future<List<dynamic>> retrieveAllBarksFromServer() async {
    final url = 'http://165.227.178.14/all/crop';
    print("retrieveAllBarks req url: $url");
    final response = await HttpController.dio.get(url);
    print("Get all Barks response body: ${response.data}");
    return response.data;
  }

  static void deleteImageFromServer(Picture image) async {
    final url = 'http://165.227.178.14/image/${image.fileId}';
    print("DeleteImageFromServer req url: $url");
    final response = await HttpController.dio.delete(url);
    print("Delete picture response body: ${response.data}");
  }

  static void deleteSongFromServer(Song song) async {
    final url = 'http://165.227.178.14/sequence/${song.fileId}';
    print("deleteSongFromServer req url: $url");
    final response = await HttpController.dio.delete(url);
    print("Delete song response body: ${response.data}");
  }

  static deleteBarkFromServer(Bark bark) async {
    final url = 'http://165.227.178.14/crop/${bark.fileId}';
    print("deleteBarkFromServer req url: $url");
    final response = await HttpController.dio.delete(url);
    print("Delete bark response body: ${response.data}");
  }

  static Future<List> splitRawBarkOnServer(fileId, imageId) async {
    Map body = {
      'uuid': fileId,
      'image_id': imageId,
    };
    print("splitRawBark req body $body");
    final url = 'http://165.227.178.14/to_crops';
    var response;
    try {
      response = await HttpController.dio.post(
        url,
        data: body,
      );
    } catch (e) {
      print("Split RAw bark error message: ${e.message}");
      print(e.response.headers);
    }
    print("split bark server response body content: ${response}");
    return response.data;
  }
}
