import 'package:http/http.dart' as http;
import 'dart:convert';

class RestAPI {
  static final Map<String, String> jsonHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };

  // this will need to be set based on env var for dev / prod
  static final String base_url = 'http://5e249d1f.ngrok.io/';
  //static final String base_url = 'https://thedogbarksthesong.ml/';

  static final String user_id = 'patrick';

  // pretty printing json
  JsonEncoder pretty_encoder = new JsonEncoder.withIndent('  ');

  // TODO pop this in all the methods below
  Future<String> request (endpoint, method, body) async {
    http.Response response;
    String url = base_url + endpoint;
    print('[rest api call] $method $url');
    try {
      if (method == 'get') {
          response = await http.get(url);
      }
      if (method == 'delete') {
          response = await http.delete(url);
      }
      if (method == 'post') {
          print('body: ' + pretty_encoder.convert(body)); 
          response = await http.post(
            url,
            body: jsonEncode(body),
            headers: jsonHeaders,
          );
      }
      if (method == 'patch') {
          print('body: ' + pretty_encoder.convert(body)); 
          response = await http.patch(
            url,
            body: jsonEncode(body),
            headers: jsonHeaders,
          );
      }
    } catch (error) {
      print('*** error with rest api call ***');
      print('url: $url');
      print('body: ' + pretty_encoder.convert(body));
      print('headers: $jsonHeaders');
      throw error;
    }
    return response.body;
  }

  // non standard api calls

  Future<String> splitRawBarkOnServer(fileId, imageId) async {
    return request('to_crops', 'post', {
      'uuid': fileId,
      'user_id': user_id,
      'image_id': imageId,
    });
  }

  Future<String> createSong(cropIds, songId) async {
    return request('to_sequence', 'post', {
      'uuids': cropIds, 
      'user_id': user_id,
      'song_id': songId.toString()
    });
  }

  // rest api


  Future<String> createImageOnServer(image) async {
    return request('image', 'post', {
      'uuid': image.fileId,
      'name': image.name,
      'user_id': user_id,
      'coordinates': image.coordinates,
    });
  }

  Future<String> retrieveAllSongsFromServer() async {
    return request('all/sequence/$user_id', 'get', Null);
  }

  Future<String> retrieveAllImagesFromServer() async {
    return request('all/image/$user_id', 'get', Null);
  }

  Future<String> retrieveAllCreatableSongsFromServer() async {
    return request('all/song/$user_id', 'get', Null);
  }

  Future<String> retrieveAllBarksFromServer() async {
    return request('all/crop/$user_id', 'get', Null);
  }

  Future<String> renameSongOnServer(song, newName) async {
    return request('sequence/${song.fileId}', 'patch', {
      'name': newName, 'user_id': user_id
    });
  }

  Future<String> updateImageOnServer(image) async {
    return request('image/${image.fileId}', 'patch', {
      'name': image.name,
      'coordinates': image.coordinates,
    });
  }

  Future<String> renameBarkOnServer(bark, newName) async {
    return request('crop/${bark.fileId}', 'patch', {
      'name': newName,
      'user_id': user_id
    });
  }

  Future<String> deleteImageFromServer(image) async {
    return request('image/${image.fileId}', 'delete', Null);
  }

  Future<String> deleteSongFromServer(song) async {
    return request('sequence/${song.fileId}', 'delete', Null);
  }

  Future<String> deleteBarkFromServer(bark) async {
    return request('crop/${bark.fileId}', 'delete', Null);
  }
}
