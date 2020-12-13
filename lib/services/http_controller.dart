import 'dart:io';

import 'package:airplane_mode_detection/airplane_mode_detection.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';

class HttpController {
  static Dio dio;
  static dynamic cookieJar;
  HttpController() {
    BaseOptions options = BaseOptions(
      contentType: Headers.jsonContentType,
      connectTimeout: 12000,
      receiveTimeout: 12000,
    );
    dio = Dio(options);
    cookieJar = PersistCookieJar(dir: myAppStoragePath + "/.cookies/");
    HttpController.dio.interceptors
        .add(CookieManager(HttpController.cookieJar));
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  static Future<Response> _catchErrors(Function httpCall) async {
    // CHECK AIRPLANE MODE
    String airplaneMode = await AirplaneModeDetection.detectAirplaneMode();
    if (airplaneMode == "Flight Mode") throw ("Please turn off Airplane Mode.");

    // ENSURE DATA CONNECTIOIN
    ConnectivityResult currentConnectivity =
        await Connectivity().checkConnectivity();
    if (currentConnectivity == ConnectivityResult.none)
      throw ("Please connect to the internet");

    Response response;

    try {
      response = await httpCall();
    } on DioError catch (e) {
      throw (e.message);
    }
    // HAPPY PATH
    print("DIO SUCCESS: $response");
    return response;
  }

  static Future<Response> dioGet(String endpoint, {options}) async {
    return _catchErrors(() async => await dio.get(endpoint, options: options));
  }

  static Future<Response> dioPost(String endpoint, {data, options}) async {
    return _catchErrors(
        () async => await dio.post(endpoint, data: data, options: options));
  }

  static Future<Response> dioDelete(String endpoint, {data}) async {
    return _catchErrors(() async => await dio.delete(endpoint, data: data));
  }

  static Future<Response> dioPut(String endpoint, {data, options}) async {
    return _catchErrors(() async => await dio.put(endpoint, data: data, options: options));
  }
}
