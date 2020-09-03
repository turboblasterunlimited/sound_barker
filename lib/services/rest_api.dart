import 'dart:convert';

import 'package:K9_Karaoke/providers/card_decoration_image.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import '../services/http_controller.dart';
import '../providers/songs.dart';
import '../providers/barks.dart';
import '../providers/pictures.dart';

class RestAPI {
  static Future<dynamic> logoutUser(email) async {
    print("logging out...");
    var response;
    try {
      response = await HttpController.dio.get("http://165.227.178.14/logout");
    } catch (e) {
      print("logout error: ${e.message}");
      return e.message;
    }
    print("logout: ${response.data["success"]}");
    return response.data["success"];
  }

  static Future<void> deleteDecorationImage(imageId) async {
    final imageUrl = 'http://165.227.178.14/decoration_image/$imageId';

    var response;
    try {
      response = await HttpController.dio.delete(
        imageUrl,
      );
    } catch (e) {
      print("delete decoration image request error message: ${e.message}");
      print(e.response.headers);
      print(e.response.data);
      print(e.response.request);
    }
    print("delete decoration image: ${response.data}");
  }

  static Future<void> deleteCardAudio(String audioId) async {
    final imageUrl = 'http://165.227.178.14/card_audio/$audioId';

    var response;
    try {
      response = await HttpController.dio.delete(
        imageUrl,
      );
    } catch (e) {
      print("delete card audio request error message: ${e.message}");
      print(e.response.headers);
      print(e.response.data);
      print(e.response.request);
    }
    print("delete card audio: ${response.data}");
  }

  static Future<void> createCardDecorationImage(
      CardDecorationImage decorationImage) async {
    final imageBody = {
      'uuid': decorationImage.fileId,
      'bucket_fp': decorationImage.bucketFp,
      'has_frame_dimension': decorationImage.hasFrameDimension == true ? 1 : 0,
    };
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
  }

  static Future<void> createCardAudio(audioOrSong) async {
    print("AUDIO STUFF: ${audioOrSong.bucketFp}, ${audioOrSong.fileId}");
    final audioBody = {
      'uuid': audioOrSong.fileId,
      'bucket_fp': audioOrSong.bucketFp
    };
    final audioUrl = 'http://165.227.178.14/card_audio';
    var response;
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
  }

  static Future updateCard(KaraokeCard card) async {
    var response;
    final cardBody = {
      'card_audio_id': card.audio.fileId,
      "image_id": card.picture.fileId,
      'decoration_image_id': card.decorationImage.fileId,
      'animation_json':
          '{"mouth_positions": ${card.audio.amplitudes.toString()}}',
    };
    final cardUrl = 'http://165.227.178.14/greeting_card/${card.uuid}';
    print("update card request body: $cardBody");
    try {
      response = await HttpController.dio.patch(
        cardUrl,
        data: cardBody,
      );
    } catch (e) {
      print("update greeting card error: ${e.message}");
      print(e.response.headers);
      print(e.response.data);
      print(e.response.request);
    }
    print("update greeting card body: ${response.data}");
    return response.data;
  }

  static Future createCard(KaraokeCard card, {songId}) async {
    var response;
    final cardBody = {
      'uuid': card.uuid,
      'card_audio_id': card.audio.fileId,
      'song_id': card.song?.fileId,
      "image_id": card.picture.fileId,
      'decoration_image_id': card.decorationImage.fileId,
      'animation_json':
          '{"mouth_positions": ${card.audio.amplitudes.toString()}}',
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
    return response.data;
  }

  static Future<Map> createSong(List<String> cropIds, int songId) async {
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

  static Future<void> renameSong(Song song, String newName) async {
    Map body = {'name': newName};
    print(body);
    final url = 'http://165.227.178.14/sequence/${song.fileId}';
    final response = await HttpController.dio.patch(
      url,
      data: body,
    );
    print("Edit bark name response body: ${response.data}");
  }

  static Future<void> updateImage(Picture image) async {
    Map body = {
      'name': image.name,
      'coordinates_json': json.encode(image.coordinates),
      'mouth_color': image.mouthColor.toString(),
    };
    print("Image update body: $body");
    final url = 'http://165.227.178.14/image/${image.fileId}';
    final response = await HttpController.dio.patch(
      url,
      data: body,
    );
    print("Edit Image on server response body: ${response.data}");
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
    final url = 'http://165.227.178.14/image';
    final response = await HttpController.dio.post(
      url,
      data: body,
    );
    return response.data;
  }

  static void renameBark(Bark bark, newName) async {
    Map body = {'name': newName};
    final url = 'http://165.227.178.14/crop/${bark.fileId}';
    final response = await HttpController.dio.patch(
      url,
      data: body,
    );
    print("Edit bark name response body: ${response.data}");
  }

  static Future<List> retrieveAllDecorationImages() async {
    final url = 'http://165.227.178.14/all/decoration_image';
    final response = await HttpController.dio.get(url);
    print("Get all decoration images response body: ${response.data}");
    return response.data;
  }

  static Future<List> retrieveAllCardAudio() async {
    final url = 'http://165.227.178.14/all/card_audio';
    final response = await HttpController.dio.get(url);
    print("Get all card audio response body: ${response.data}");
    return response.data;
  }

  static Future<List> retrieveAllSongs() async {
    final url = 'http://165.227.178.14/all/sequence';
    final response = await HttpController.dio.get(url);
    print("Get all Songs response body: ${response.data}");
    return response.data;
  }

  static Future<List> retrieveAllCards() async {
    final url = 'http://165.227.178.14/all/greeting_card';
    final response = await HttpController.dio.get(url);
    print("Get all Cards response body: ${response.data}");
    return response.data;
  }

  static Future<List> retrieveAllImages() async {
    final url = 'http://165.227.178.14/all/image';
    print("retrieveAllImages req url: $url");
    final response = await HttpController.dio.get(url);
    print("Get all Images response body: ${response.data}");
    return response.data;
  }

  static Future<List> retrieveAllCreatableSongs() async {
    final url = 'http://165.227.178.14/all/song';
    print("retrieveAllCreatableSongs req url: $url");
    final response = await HttpController.dio.get(url);
    print("Get all Creatable Songs response body: ${response.data}");
    return response.data;
  }

  static Future<List<dynamic>> retrieveAllBarks() async {
    final url = 'http://165.227.178.14/all/crop';
    print("retrieveAllBarks req url: $url");
    final response = await HttpController.dio.get(url);
    print("Get all Barks response body: ${response.data}");
    return response.data;
  }

  static void deleteImage(Picture image) async {
    final url = 'http://165.227.178.14/image/${image.fileId}';
    print("deleteImage req url: $url");
    final response = await HttpController.dio.delete(url);
    print("Delete picture response body: ${response.data}");
  }

  static Future<void> deleteCard(KaraokeCard card) async {
    final url = 'http://165.227.178.14/greeting_card/${card.uuid}';
    print("delete Card req url: $url");
    final response = await HttpController.dio.delete(url);
    print("Delete card response body: ${response.data}");
  }

  static void deleteSong(Song song) async {
    final url = 'http://165.227.178.14/sequence/${song.fileId}';
    print("deleteSong req url: $url");
    final response = await HttpController.dio.delete(url);
    print("Delete song response body: ${response.data}");
  }

  static deleteBark(Bark bark) async {
    final url = 'http://165.227.178.14/crop/${bark.fileId}';
    print("deleteBark req url: $url");
    final response = await HttpController.dio.delete(url);
    print("Delete bark response body: ${response.data}");
  }

  static Future<List> splitRawBark(fileId, imageId) async {
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
