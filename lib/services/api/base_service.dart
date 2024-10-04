import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class BaseService {
  static Future<T> get2<T>(String url, T Function(String json) fromJson) async {
    var uri = Uri.parse(url);
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var response = await client.get(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
    );
    client.close();
    return fromJson(response.body);
  }

  static Future<T?> add2<T>(
      String url, String jsonData, T Function(String json) fromJson) async {
    var uri = Uri.parse(url);
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var response = await client.post(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
      body: jsonData,
    );
    client.close();
    return fromJson(response.body);
  }

  static Future<T> update2<T>(
      String url, String? jsonData, T Function(String json) fromJson) async {
    var uri = Uri.parse(url);
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var response = await client.put(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
      body: jsonData,
    );
    client.close();
    return fromJson(response.body);
  }

  static Future<T> delete2<T>(
      String url, T Function(String json) fromJson) async {
    var uri = Uri.parse(url);
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var response = await client.delete(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
    );
    client.close();
    return fromJson(response.body);
  }

  static Future<http.Response> get(String url, int id) async {
    var uri = Uri.parse("$url/get?id=$id");
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var response = await client.get(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
    );
    client.close();
    return response;
  }

  static Future<http.Response> getAll(String url) async {
    var uri = Uri.parse("$url/getall");
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var response = await client.get(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
    );
    client.close();
    return response;
  }

  static Future<http.Response> add(String url, String jsonData) async {
    var uri = Uri.parse("$url/add");
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var response = await client.post(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
      body: jsonData,
    );
    client.close();
    return response;
  }

  static Future<http.Response> update(String url, String jsonData) async {
    var uri = Uri.parse("$url/update");
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var response = await client.put(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
      body: jsonData,
    );
    client.close();
    return response;
  }

  static Future<http.Response> delete(String url, int id) async {
    var uri = Uri.parse("$url/delete?id=$id");
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    print(uri.toString());
    var response = await client.delete(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
    );
    client.close();
    return response;
  }
}
