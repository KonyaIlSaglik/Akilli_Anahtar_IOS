import 'dart:convert';

import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/models/result.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class BoxService {
  static String url = "$apiUrlOut/Box";

  static Future<Box?> get(int id) async {
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var uri = Uri.parse("$url/get?id=$id");
    var client = http.Client();
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
      var box = Box.fromJson(json.encode(result["data"]));
      return box;
    }
    return null;
  }

  static Future<List<Box>?> getAll() async {
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var uri = Uri.parse("$url/getall");
    var client = http.Client();
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
      var boxList = List<Box>.from((result["data"] as List<dynamic>)
          .map((e) => Box.fromJson(json.encode(e))));
      return boxList;
    }
    return null;
  }

  static Future<Result> add(Box box) async {
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var uri = Uri.parse("$url/add");
    var client = http.Client();
    var response = await client.post(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
      body: box.toJson(),
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

  static Future<Result> update(Box box) async {
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var uri = Uri.parse("$url/update");
    var client = http.Client();
    var response = await client.put(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
      body: box.toJson(),
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

  static Future<Result> delete(int id) async {
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var uri = Uri.parse("$url/delete?id=$id");
    var client = http.Client();
    var response = await client.delete(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
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

  static Future<String> checkNewVersion() async {
    try {
      var uri = Uri.parse("https://www.ossbs.com/update/version.html");
      var client = http.Client();
      var response = await client.get(uri);
      if (response.statusCode == 200) {
        var s1 = response.body.split(":");
        var s2 = s1[1].split("-");
        return s2[0];
      }
    } catch (e) {
      print(e);
      return "";
    }
    return "";
  }
}
