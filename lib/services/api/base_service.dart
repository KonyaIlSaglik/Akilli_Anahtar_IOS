import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class BaseService {
  static Future<http.Response> get(String url) async {
    try {
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
      print(url);
      print(response.statusCode);
      print(response.body);
      return response;
    } catch (e) {
      print(e);
      return http.Response("hata", 999);
    }
  }

  static Future<http.Response> add(String url, String jsonData) async {
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
    print(url);
    print(response.statusCode);
    print(response.body);
    return response;
  }

  static Future<http.Response> update(String url, String? jsonData) async {
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
    print(url);
    print(response.statusCode);
    print(response.body);
    return response;
  }

  static Future<http.Response> delete(String url) async {
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
    print(url);
    print(response.statusCode);
    print(response.body);
    return response;
  }
}
