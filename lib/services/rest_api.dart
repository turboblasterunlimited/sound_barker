import 'dart:convert';

import 'package:K9_Karaoke/providers/card_decoration_image.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import '../services/http_controller.dart';
import '../providers/songs.dart';
import '../providers/barks.dart';
import '../providers/pictures.dart';
import 'package:K9_Karaoke/globals.dart';

Map<String, dynamic> noInternetResponse = {
  "error": "You must be connected to the internet",
  "success": false
};

class RestAPI {
  static dynamic _handleAccountError(response, e) {
    print("Error: $e");
    if (response == null) return noInternetResponse;
    response?.data["success"] = false;
    response?.data["error"] = e.message;
    return response;
  }

  static _handleAssetError(response, e) {
    if (response == null) return noInternetResponse;
    print(e.response.headers);
    print(e.response.data);
    print(e.response.request);
  }

  static Future<dynamic> userManualSignUp(email, password) async {
    Map data = {"email": email.toLowerCase(), "password": password};
    var response;
    try {
      response = await HttpController.dio.post(
        'http://$serverIP/create-account',
        data: data,
      );
    } catch (e) {
      return _handleAccountError(response, e);
    }
    return response?.data;
  }

  static Future<dynamic> userManualSignIn(email, password) async {
    Map data = {"email": email?.toLowerCase(), "password": password};
    var response;
    try {
      response = await HttpController.dio.post(
        'http://$serverIP/manual-login',
        data: data,
      );
      print("Manual sign in response: $response");
      print("Manual sign in response: ${response?.data}");
    } catch (e) {
      print("manual sign in error: $e");
      return _handleAccountError(response, e);
    }
    return response?.data;
  }

  static Future<dynamic> deleteUser(email) async {
    print("Deleting account...");
    var response;
    try {
      response =
          await HttpController.dio.post("http://$serverIP/delete-account");
    } catch (e) {
      return _handleAccountError(response, e);
    }
    return response?.data;
  }

  static Future<dynamic> logoutUser(email) async {
    print("logging out...");
    var response;
    try {
      response = await HttpController.dio.get("http://$serverIP/logout");
    } catch (e) {
      return _handleAccountError(response, e);
    }
    return response?.data;
  }

  static Future<void> deleteDecorationImage(imageId) async {
    final imageUrl = 'http://$serverIP/decoration_image/$imageId';

    var response;
    try {
      response = await HttpController.dio.delete(
        imageUrl,
      );
    } catch (e) {
      print("delete decoration image request error message: ${e.message}");
      _handleAssetError(response, e);
    }
  }

  static Future<void> deleteCardAudio(String audioId) async {
    final imageUrl = 'http://$serverIP/card_audio/$audioId';

    var response;
    try {
      response = await HttpController.dio.delete(
        imageUrl,
      );
    } catch (e) {
      print("delete card audio request error message: ${e.message}");
      _handleAssetError(response, e);
    }
  }

  static Future<void> updateCardPicture(card) async {
    var response;
    final cardBody = {"image_id": card.picture.fileId};
    final cardUrl = 'http://$serverIP/greeting_card/${card.uuid}';
    print("update card request body: $cardBody");
    try {
      response = await HttpController.dio.patch(
        cardUrl,
        data: cardBody,
      );
    } catch (e) {
      print("update card picture error: ${e.message}");
      _handleAssetError(response, e);
    }
    return response?.data;
  }

  static Future<void> createCardDecorationImage(
      CardDecorationImage decorationImage) async {
    final imageBody = {
      'uuid': decorationImage.fileId,
      'bucket_fp': decorationImage.bucketFp,
      'has_frame_dimension': decorationImage.hasFrameDimension ? 1 : 0,
    };
    final imageUrl = 'http://$serverIP/decoration_image';

    var response;
    try {
      response = await HttpController.dio.post(
        imageUrl,
        data: imageBody,
      );
    } catch (e) {
      print("create decoration image: ${e.message}");
      _handleAssetError(response, e);
    }
  }

  static Future<void> createCardAudio(audioOrSong) async {
    print("AUDIO STUFF: ${audioOrSong.bucketFp}, ${audioOrSong.fileId}");
    final audioBody = {
      'uuid': audioOrSong.fileId,
      'bucket_fp': audioOrSong.bucketFp
    };
    final audioUrl = 'http://$serverIP/card_audio';
    var response;
    try {
      response = await HttpController.dio.post(
        audioUrl,
        data: audioBody,
      );
    } catch (e) {
      print("create card audio error: ${e.message}");
      _handleAssetError(response, e);
    }
  }

  static Future updateCard(KaraokeCard card) async {
    var response;
    final cardBody = {
      'card_audio_id': card.audio.fileId,
      "image_id": card.picture.fileId,
      'decoration_image_id': card.decorationImage?.fileId,
      'animation_json':
          '{"mouth_positions": ${card.audio.amplitudes.toString()}}',
    };
    final cardUrl = 'http://$serverIP/greeting_card/${card.uuid}';
    print("update card request body: $cardBody");
    try {
      response = await HttpController.dio.patch(
        cardUrl,
        data: cardBody,
      );
    } catch (e) {
      print("update greeting card error: ${e.message}");
      _handleAssetError(response, e);
    }
    return response?.data;
  }

  static Future createCard(KaraokeCard card, {songId}) async {
    var response;
    final cardBody = {
      'uuid': card.uuid,
      'card_audio_id': card.audio.fileId,
      'song_id': card.song?.fileId,
      "image_id": card.picture.fileId,
      'decoration_image_id': card.decorationImage?.fileId,
      'animation_json':
          '{"mouth_positions": ${card.audio.amplitudes.toString()}}',
    };
    final cardUrl = 'http://$serverIP/greeting_card';
    print("card request body: $cardBody");
    try {
      response = await HttpController.dio.post(
        cardUrl,
        data: cardBody,
      );
    } catch (e) {
      print("create greeting card error: ${e.message}");
      _handleAssetError(response, e);
    }
    print("create greeting card body: ${response?.data}");
    return response?.data;
  }

  static Future<Map> createSong(List<String> cropIds, int songId) async {
    /// "Song" on the server side means "creatable song"
    Map body = {'uuids': cropIds, 'song_id': songId.toString()};
    print("create song on server req body: $body");
    final url = 'http://$serverIP/to_sequence';
    var response;
    try {
      response = await HttpController.dio.post(
        url,
        data: body,
      );
    } catch (e) {
      print("Split RAw bark error message: ${e.message}");
      _handleAssetError(response, e);
    }
    print("create Song on server response body: ${response?.data}");
    return response?.data;
  }

  static Future<void> renameSong(Song song, String newName) async {
    Map body = {'name': newName};
    print(body);
    final url = 'http://$serverIP/sequence/${song.fileId}';
    var response;
    try {
      response = await HttpController.dio.patch(
        url,
        data: body,
      );
    } catch (e) {
      print("Edit bark name response body: ${response?.data}");
      _handleAssetError(response, e);
    }
    return response?.data;
  }

  static Future<void> updateImageName(Picture image) async {
    Map body = {
      'name': image.name,
    };
    print("Image update body: $body");
    final url = 'http://$serverIP/image/${image.fileId}';
    var response;
    try {
      response = await HttpController.dio.patch(
        url,
        data: body,
      );
    } catch (e) {
      print("Edit Image Name on server response body: ${response?.data}");
      _handleAssetError(response, e);
    }
    print("Update image response data: ${response.data}");
    return response?.data;
  }

  static Future<void> updateImage(Picture image) async {
    Map body = {
      'name': image.name,
      'coordinates_json': json.encode(image.coordinates),
      'mouth_color': image.mouthColor.toString(),
    };
    print("Image update body: $body");
    final url = 'http://$serverIP/image/${image.fileId}';
    var response;
    try {
      response = await HttpController.dio.patch(
        url,
        data: body,
      );
    } catch (e) {
      print("Edit Image on server response body: ${response?.data}");
      _handleAssetError(response, e);
    }
    return response?.data;
  }

  static Future<Map> createImage(Picture image) async {
    Map body = {
      'uuid': image.fileId,
      'name': image.name,
      'coordinates_json': json.encode(image.coordinates),
      'mouth_color': image.mouthColor,
      'bucket_fp': image.fileUrl,
    };
    print("Image upload body: $body");
    final url = 'http://$serverIP/image';
    var response;
    try {
      response = await HttpController.dio.post(
        url,
        data: body,
      );
    } catch (e) {
      print("Create Image response body: ${response?.data}");
      _handleAssetError(response, e);
    }
    return response?.data;
  }

  static void renameBark(Bark bark, newName) async {
    Map body = {'name': newName};
    final url = 'http://$serverIP/crop/${bark.fileId}';
    var response;
    try {
      response = await HttpController.dio.patch(
        url,
        data: body,
      );
    } catch (e) {
      print("Edit bark name response body: ${response?.data}");
      _handleAssetError(response, e);
    }
    return response?.data;
  }

  static Future<List> retrieveAllDecorationImages() async {
    final url = 'http://$serverIP/all/decoration_image';
    var response;
    try {
      response = await HttpController.dio.get(url);
    } catch (e) {
      print("Get all decoration images response body: ${response?.data}");
      _handleAssetError(response, e);
    }
    return response?.data;
  }

  static Future<List> retrieveAllCardAudio() async {
    final url = 'http://$serverIP/all/card_audio';
    var response;
    try {
      response = await HttpController.dio.get(url);
    } catch (e) {
      print("Get all card audio response body: ${response?.data}");
      _handleAssetError(response, e);
    }
    return response?.data;
  }

  static Future<List> retrieveAllSongs() async {
    final url = 'http://$serverIP/all/sequence';
    var response;
    try {
      response = await HttpController.dio.get(url);
    } catch (e) {
      print("Get all Songs response body: ${response?.data}");
      _handleAssetError(response, e);
    }
    return response?.data;
  }

  static Future<List> retrieveAllCards() async {
    final url = 'http://$serverIP/all/greeting_card';
    var response;
    try {
      response = await HttpController.dio.get(url);
    } catch (e) {
      print(
          "Get all Cards response body: ${response?.data.map((card) => card["hidden"])}");
      _handleAssetError(response, e);
    }
    return response?.data;
  }

  static Future<List> retrieveAllImages() async {
    final url = 'http://$serverIP/all/image';
    print("retrieveAllImages req url: $url");
    var response;
    try {
      response = await HttpController.dio.get(url);
    } catch (e) {
      print("Get all Images response body: ${response?.data}");
      _handleAssetError(response, e);
    }
    return response?.data;
  }

  static Future<List> retrieveAllCreatableSongs() async {
    final url = 'http://$serverIP/all/song';
    print("retrieveAllCreatableSongs req url: $url");
    var response;
    try {
      response = await HttpController.dio.get(url);
    } catch (e) {
      print("Get all Creatable Songs response body: ${response?.data}");
      _handleAssetError(response, e);
    }
    return response?.data;
  }

  static Future<List<dynamic>> retrieveAllBarks() async {
    final url = 'http://$serverIP/all/crop';
    print("retrieveAllBarks req url: $url");
    var response;
    try {
      response = await HttpController.dio.get(url);
    } catch (e) {
      print("Get all Barks response body: ${response?.data}");
      _handleAssetError(response, e);
    }
    return response?.data;
  }

  static void deleteImage(Picture image) async {
    final url = 'http://$serverIP/image/${image.fileId}';
    print("deleteImage req url: $url");
    var response;
    try {
      response = await HttpController.dio.delete(url);
    } catch (e) {
      print("Delete picture response body: ${response?.data}");
      _handleAssetError(response, e);
    }
  }

  static Future<void> deleteCard(KaraokeCard card) async {
    final url = 'http://$serverIP/greeting_card/${card.uuid}';
    print("delete Card req url: $url");
    var response;
    try {
      response = await HttpController.dio.delete(url);
    } catch (e) {
      print("Delete card response body: ${response?.data}");
      _handleAssetError(response, e);
    }
  }

  static void deleteSong(Song song) async {
    final url = 'http://$serverIP/sequence/${song.fileId}';
    print("deleteSong req url: $url");
    var response;
    try {
      response = await HttpController.dio.delete(url);
    } catch (e) {
      _handleAssetError(response, e);
    }
    print("Delete song response body: ${response?.data}");
  }

  static deleteBark(Bark bark) async {
    final url = 'http://$serverIP/crop/${bark.fileId}';
    print("deleteBark req url: $url");
    var response;
    try {
      response = await HttpController.dio.delete(url);
    } catch (e) {
      _handleAssetError(response, e);
    }
    print("Delete bark response body: ${response?.data}");
  }

  static Future<List> splitRawBark(fileId, imageId) async {
    Map body = {
      'uuid': fileId,
      'image_id': imageId,
    };
    print("splitRawBark req body $body");
    final url = 'http://$serverIP/to_crops';
    var response;
    try {
      response = await HttpController.dio.post(
        url,
        data: body,
      );
    } catch (e) {
      print("Split RAw bark error message: ${e.message}");
      _handleAssetError(response, e);
    }
    print("split bark server response body content: ${response}");
    return response?.data;
  }
}
