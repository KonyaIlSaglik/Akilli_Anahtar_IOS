import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/models/data_result.dart';
import 'dart:convert';
import 'package:akilli_anahtar/models/result.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class UserService {
  static String url = "$apiUrlOut/User";

  static Future<User?> getbyUserName(String userName) async {
    var uri = Uri.parse("$url/getbyusername?user_name=$userName");
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

    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      var user = User.fromJson(json.encode(result["data"]));
      return user;
    }
    return null;
  }

  static Future<User?> get(int id) async {
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
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      var user = User.fromJson(json.encode(result["data"]));
      return user;
    }
    return null;
  }

  static Future<List<User>?> getAll() async {
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
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      var userList = List<User>.from((result["data"] as List<dynamic>)
          .map((e) => User.fromJson(json.encode(e))));
      return userList;
    }
    return null;
  }

  static Future<Result> add(User user) async {
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
      body: user.toJson(),
    );
    client.close();
    var result = Result();
    if (response.statusCode == 200) {
      var body = json.decode(response.body) as Map<String, dynamic>;
      result.success = body["success"] as bool;
      result.message = body["message"] ?? "";
    }
    return result;
  }

  static Future<Result> update(User user) async {
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
      body: user.toJson(),
    );
    client.close();
    var result = Result();
    if (response.statusCode == 200) {
      var body = json.decode(response.body) as Map<String, dynamic>;
      result.success = body["success"] as bool;
      result.message = body["message"] ?? "";
    }
    return result;
  }
}
