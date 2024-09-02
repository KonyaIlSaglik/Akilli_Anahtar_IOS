import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/entities/parameter.dart';
import 'dart:convert';
import 'package:akilli_anahtar/models/result.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ParameterService {
  static String url = "$apiUrlOut/Parameter";

  static Future<List<Parameter>?> getParametersbyType(int type) async {
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var uri = Uri.parse("$url/parametersbytype?type=$type");
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
      var list = List<Parameter>.from(
        (result["data"] as List<dynamic>)
            .map((e) => Parameter.fromMap(e as Map<String, dynamic>)),
      );
      return list;
    }
    return null;
  }

  static Future<Parameter?> getbyName(String name) async {
    var uri = Uri.parse("$url/parameterbyname?name=$name");
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
      var parameter = Parameter.fromJson(json.encode(result["data"]));
      return parameter;
    }
    return null;
  }

  static Future<Parameter?> get(int id) async {
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
      var parameter = Parameter.fromJson(json.encode(result["data"]));
      return parameter;
    }
    return null;
  }

  static Future<List<Parameter>?> getAll() async {
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
      var parameterList = List<Parameter>.from((result["data"] as List<dynamic>)
          .map((e) => Parameter.fromJson(json.encode(e))));
      return parameterList;
    }
    return null;
  }

  static Future<Result> add(Parameter parameter) async {
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
      body: parameter.toJson(),
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

  static Future<Result> update(Parameter parameter) async {
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
      body: parameter.toJson(),
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
