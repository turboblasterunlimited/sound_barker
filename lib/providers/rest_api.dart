import 'package:http/http.dart' as http;
import 'dart:convert';

class RestAPI {
  final Map jsonHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  Future<String> createPet(petId, petName) async {
    http.Response response;
    final url = 'http://165.227.178.14/pet';
    try {
      response = await http.post(
        url,
        body: json.encode({'name': petName, 'userId': '999'}),
        headers: jsonHeaders,
      );
    } catch (error) {
      print(error);
      throw error;
    }
    return response.body;
  }

  Future<String> splitRawBark(fileId) async {
    http.Response response;
    final url = 'http://165.227.178.14/split_audio';
    try {
      response = await http.post(
        url,
        body: json.encode({
          'uuid': fileId,
        }),
        headers: jsonHeaders,
      );
    } catch (error) {
      print(error);
      throw error;
    }
    print("Response body content: ${response.body}");
    return response.body;
  }

  Future<void> notifyServerRawBarkInBucket(fileId, petId) async {
    http.Response response;
    // User ID hardcoded as 999 for now.
    final url = 'http://165.227.178.14/raw';
    try {
      response = await http.post(
        url,
        body: json.encode({
          'user_id': '999',
          'uuid': fileId,
          'pet_id': petId,
        }),
        headers: jsonHeaders,
      );
    } catch (error) {
      print(error);
      throw error;
    }
    print("Response body content: ${response.body}");
  }
}
