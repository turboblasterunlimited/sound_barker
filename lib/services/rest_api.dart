import 'package:http/http.dart' as http;
import 'dart:convert';

class RestAPI {
  final Map<String, String> jsonHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };

  Future<String> createSong(cropId, songTitle, petId) async {
    http.Response response;
    String body = json.encode(
        {'uuid': cropId, 'name': songTitle, 'user_id': '999', 'pet_id': petId});
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
    print("create pet on server response body: ${response.body}");
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

  Future<String> renameBarkOnServer(bark) async {
    http.Response response;
    String body = json.encode({'name': bark.name, "user_id": "999"});
    //print(body);
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
    //print("Edit bark name response body: ${response.body}");
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
    http.Response response;
    final url = 'http://165.227.178.14/sequence/${song.fileId}';
    try {
      response = await http.delete(url);
    } catch (error) {
      //print(error);
      throw error;
    }
    //print("Delete bark response body: ${response.body}");
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
    //print("Delete bark response body: ${response.body}");
    return response.body;
  }

  Future<String> createPetOnServer(petName) async {
    http.Response response;
    String body = json.encode({'name': petName, 'user_id': '999'});
    //print(body);
    final url = 'http://165.227.178.14/pet';
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
    //print("create pet on server response body: ${response.body}");
    return response.body;
  }

  Future<String> splitRawBarkOnServer(fileId, petId) async {
    http.Response response;
    String body = json.encode({
      'uuid': fileId,
      'user_id': '999',
      'pet_id': petId,
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

  Future<void> notifyServerRawBarkInBucket(fileId, petId) async {
    http.Response response;
    String body = json.encode({
      'user_id': '999',
      'uuid': fileId,
      'pet_id': petId,
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

// var exampleResponse = {
//   "crops": [
//     {
//       "uuid": "11351e26-c976-4c41-aef3-bea759827b5d",
//       "raw_id": "1d3204df-328e-4df0-8d8c-bd510e7fa65b",
//       "user_id": "tovi-id",
//       "name": null,
//       "bucket_url": "gs://1d3204df-328e-4df0-8d8c-bd510e7fa65b/cropped/11351e26-c976-4c41-aef3-bea759827b5d.aac",
//       "bucket_fp": "1d3204df-328e-4df0-8d8c-bd510e7fa65b/cropped/11351e26-c976-4c41-aef3-bea759827b5d.aac",
//       "stream_url": null,
//       "hidden": 0,
//       "obj_type": "crop"
//     },
//     {
//       "uuid": "c966b714-f983-4e82-a199-37c64880f9ab",
//       "raw_id": "1d3204df-328e-4df0-8d8c-bd510e7fa65b",
//       "user_id": "tovi-id",
//       "name": null,
//       "bucket_url": "gs://1d3204df-328e-4df0-8d8c-bd510e7fa65b/cropped/c966b714-f983-4e82-a199-37c64880f9ab.aac",
//       "bucket_fp": "1d3204df-328e-4df0-8d8c-bd510e7fa65b/cropped/c966b714-f983-4e82-a199-37c64880f9ab.aac",
//       "stream_url": null,
//       "hidden": 0,
//       "obj_type": "crop"
//     },
//     {
//       "uuid": "e678aa6f-ac2c-46a2-b20c-889503e31e36",
//       "raw_id": "1d3204df-328e-4df0-8d8c-bd510e7fa65b",
//       "user_id": "tovi-id",
//       "name": null,
//       "bucket_url": "gs://1d3204df-328e-4df0-8d8c-bd510e7fa65b/cropped/e678aa6f-ac2c-46a2-b20c-889503e31e36.aac",
//       "bucket_fp": "1d3204df-328e-4df0-8d8c-bd510e7fa65b/cropped/e678aa6f-ac2c-46a2-b20c-889503e31e36.aac",
//       "stream_url": null,
//       "hidden": 0,
//       "obj_type": "crop"
//     }
//   ],
//   "pet": {
//     "pet_id": 1,
//     "user_id": "tovi-id",
//     "name": "woofer",
//     "image_url": null,
//     "hidden": 0,
//     "obj_type": "pet"
//   }
// };
