import '../services/http_controller.dart';
import '../providers/songs.dart';
import '../providers/barks.dart';
import '../providers/pictures.dart';

class RestAPI {
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

  static void renameSongOnServer(Song song, String newName) async {
    Map body = {'name': newName};
    print(body);
    final url = 'http://165.227.178.14/sequence/${song.fileId}';
    final response = await HttpController.dio.patch(
      url,
      data: body,
    );
    print("Edit bark name response body: ${response.data}");
  }

  static void updateImageOnServer(Picture image) async {
    Map body = {
      'name': image.name,
      'coordinates_json': image.coordinates,
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
      'coordinates_json': image.coordinates,
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
