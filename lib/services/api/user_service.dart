import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/models/data_result.dart';
import 'package:akilli_anahtar/models/register_model.dart';
import 'package:akilli_anahtar/models/result.dart';
import 'dart:convert';
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
    if (response.statusCode == 401) {
      authController.logOut();
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

  static Future<DataResult<User>> register(RegisterModel registerModel) async {
    var uri = Uri.parse("$url/register");
    var client = http.Client();
    var response = await client.post(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
      },
      body: registerModel.toJson(),
    );
    client.close();
    var dataResult = DataResult<User>();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      dataResult.data = User.fromJson(json.encode(result["data"]));
      dataResult.success = result["success"];
      dataResult.message = result["message"];
    } else {
      dataResult.success = false;
      dataResult.message = response.body;
    }
    return dataResult;
  }

  static Future<DataResult<User>> update(User user) async {
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
    print(user.toJson());
    client.close();
    print(response.body);
    var dataResult = DataResult<User>();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      dataResult.data = User.fromJson(json.encode(result["data"]));
      dataResult.success = result["success"];
      dataResult.message = result["message"];
    } else {
      dataResult.success = false;
      dataResult.message = response.body;
    }
    return dataResult;
  }

  static Future<Result> delete(id) async {
    var uri = Uri.parse("$url/delete?id=$id");
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
    print(response.body);
    var result = Result();
    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body) as Map<String, dynamic>;
      result.success = jsonResult["success"];
      result.message = jsonResult["message"];
    } else {
      result.success = false;
      result.message = response.body;
    }
    return result;
  }

  static Future<Result> passUpdate(int id, String password) async {
    var uri = Uri.parse("$url/passupdate?id=$id&password=$password");
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var response = await client.put(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
    );
    client.close();
    var result = Result();
    var data = json.decode(response.body) as Map<String, dynamic>;
    result.success = data["success"];
    result.message = data["message"];
    return result;
  }
}
