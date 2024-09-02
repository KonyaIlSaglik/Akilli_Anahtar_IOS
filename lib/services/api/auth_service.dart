import 'dart:convert';
import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/models/data_result.dart';
import 'package:akilli_anahtar/models/login_model.dart';
import 'package:akilli_anahtar/models/register_model.dart';
import 'package:akilli_anahtar/models/token_model.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:platform_device_id/platform_device_id.dart';

class AuthService {
  static String url = "$apiUrlOut/Auth";

  static Future<TokenModel?> login(LoginModel loginModel) async {
    loginModel.identity = await PlatformDeviceId.getDeviceId ?? "";
    var uri = Uri.parse("$url/login");
    var client = http.Client();
    var response = await client.post(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
      },
      body: loginModel.toJson(),
    );
    client.close();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      var tokenModel = TokenModel.fromJson(json.encode(result["data"]));
      return tokenModel;
    }
    return null;
  }

  static Future<DataResult<TokenModel>> register(
      RegisterModel registerModel) async {
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
    var dataResult = DataResult<TokenModel>();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      dataResult.data = TokenModel.fromJson(json.encode(result["data"]));
      dataResult.success = result["success"];
      dataResult.message = result["message"];
    } else {
      dataResult.success = false;
      dataResult.message = response.body;
    }
    return dataResult;
  }

  static Future<void> logOut() async {
    var info = await LocalDb.get(userKey);
    var user = User.fromJson(info!);
    var identity = await PlatformDeviceId.getDeviceId ?? "";
    var uri =
        Uri.parse("$url/changepassword?userId=${user.id}&identity=$identity");
    var client = http.Client();
    print("logout");
    var response = await client.post(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
      },
    );
    client.close();
  }

  static Future<DataResult<TokenModel>> changePassword(
      String oldPassword, String newPassword) async {
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var info = await LocalDb.get(userKey);
    var user = User.fromJson(info!);
    var uri = Uri.parse(
        "$url/changepassword?userId=${user.id}&oldPasword=$oldPassword&newPassword=$newPassword");
    var client = http.Client();

    var response = await client.put(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
    );
    client.close();
    var dataResult = DataResult<TokenModel>();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      dataResult.data = TokenModel.fromJson(json.encode(result["data"]));
      dataResult.success = result["success"];
      dataResult.message = result["message"];
    } else {
      dataResult.success = false;
      dataResult.message = response.body;
    }
    return dataResult;
  }
}
