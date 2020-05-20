import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:song_barker/functions/app_storage_path.dart';

class HttpController {
  static Dio dio;
  static dynamic cookieJar;
  HttpController() {
    BaseOptions options = BaseOptions(contentType: Headers.jsonContentType);
    dio = Dio(options);
    cookieJar = PersistCookieJar(dir: myAppStoragePath + "/.cookies/");
    HttpController.dio.interceptors.add(CookieManager(HttpController.cookieJar));
  }
}

