import 'dart:convert';
import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/models/data_result.dart';
import 'package:akilli_anahtar/models/login_model.dart';
import 'package:akilli_anahtar/models/token_model.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static String url = "$apiUrlOut/Auth";

  static Future<TokenModel?> login(LoginModel loginModel) async {
    AuthController authController = Get.find();
    loginModel.identity = await authController.getDeviceId();
    print(loginModel.identity);
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
        var result = json.decode(response.body) as Map<String, dynamic>;
        var tokenModel = TokenModel.fromJson(json.encode(result["data"]));
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

  static Future<DataResult<List<OperationClaim>>> getClaims(User user) async {
    var uri = Uri.parse("$url/getuserclaims");
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
    var dataResult = DataResult<List<OperationClaim>>();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      dataResult.data =
          OperationClaim.fromJsonList(json.encode(result["data"]));
      dataResult.success = result["success"];
      dataResult.message = result["message"] ?? "";
    } else {
      dataResult.success = false;
      dataResult.message = response.body;
    }
    return dataResult;
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

  static Future<DataResult<TokenModel>> changePassword(
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
    print(uri.path);
    var response = await client.put(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
      body: json.encode(requestBody),
    );
    client.close();
    print(response.body);
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
