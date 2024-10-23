import 'dart:convert';
import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/models/login_model.dart';
import 'package:akilli_anahtar/models/login_model2.dart';
import 'package:akilli_anahtar/models/token_model.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static String url = "$apiUrlOut/Auth";

  static Future<TokenModel?> login(LoginModel loginModel) async {
    AuthController authController = Get.find();
    loginModel.identity = await authController.getDeviceId();
    var uri = Uri.parse("$url/login");
    var client = http.Client();
    try {
      var response = await client.post(
        uri,
        headers: {
          'content-type': 'application/json; charset=utf-8',
        },
        body: loginModel.toJson(),
      );
      client.close();
      if (response.statusCode == 200) {
        var tokenModel = TokenModel.fromJson(response.body);
        return tokenModel;
      }
      if (response.statusCode == 400) {
        errorSnackbar("Hata", response.body);
      }
    } catch (e) {
      errorSnackbar("Hata", "Oturum Açma Sırasında bir hata oluştu.");
      print(e);
    }
    return null;
  }

  static Future<TokenModel?> login2(LoginModel2 loginModel) async {
    AuthController authController = Get.find();
    loginModel.identity = await authController.getDeviceId();
    loginModel.platformName = await authController.getDeviceName();
    var uri = Uri.parse("$url/login2");
    var client = http.Client();
    try {
      var response = await client.post(
        uri,
        headers: {
          'content-type': 'application/json; charset=utf-8',
        },
        body: loginModel.toJson(),
      );
      client.close();
      if (response.statusCode == 200) {
        var data = json.decode(response.body) as Map<String, dynamic>;
        var tokenModel = TokenModel.fromJson(data["session"]);
        return tokenModel;
      }
      if (response.statusCode == 400) {
        errorSnackbar("Hata", response.body);
      }
    } catch (e) {
      errorSnackbar("Hata", "Oturum Açma Sırasında bir hata oluştu.");
      print(e);
    }
    return null;
  }

  static Future<List<OperationClaim>?> getUserClaims() async {
    var authController = Get.find<AuthController>();
    var response = await BaseService.get(
        "$url/getUserClaims?id=${authController.user.value.id}");
    if (response.statusCode == 200) {
      return OperationClaim.fromJsonList(response.body);
    }
    return null;
  }

  static Future<void> logOut() async {
    AuthController authController = Get.find();
    var identity = await authController.getDeviceId();
    var uri = Uri.parse("$url/logout?identity=$identity");
    var client = http.Client();
    var response = await client.post(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
      },
    );
    client.close();
    if (response.statusCode == 200) {
      successSnackbar("Başarılı", response.body);
    } else {
      errorSnackbar("Hata", response.body);
    }
  }

  static Future<TokenModel?> changePassword(
      String oldPassword, String newPassword) async {
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var requestBody = {
      'userId': authController.user.value.id,
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
    var uri = Uri.parse("$url/changepassword");
    var client = http.Client();
    var response = await client.put(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
      body: json.encode(requestBody),
    );
    client.close();
    if (response.statusCode == 200) {
      var data = TokenModel.fromJson(json.encode(response.body));
      return data;
    }
    return null;
  }
}
