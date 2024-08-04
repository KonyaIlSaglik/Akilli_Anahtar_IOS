import 'dart:convert';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/models/data_result.dart';
import 'package:akilli_anahtar/models/login_model.dart';
import 'package:akilli_anahtar/models/token_model.dart';
import 'package:akilli_anahtar/services/api/user_service.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static String url = "${apiUrlOut}Auth";

  static Future<DataResult<TokenModel>?> login(LoginModel loginModel) async {
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
    var dataResult = DataResult<TokenModel>();
    if (response.statusCode == 200) {
      await LocalDb.add(passwordKey, loginModel.password);
      var result = json.decode(response.body) as Map<String, dynamic>;
      dataResult.data = TokenModel.fromJson(json.encode(result["data"]));
      dataResult.success = result["success"];
      dataResult.message = result["message"];
      await LocalDb.add(tokenModelKey, json.encode(result["data"]));
      var user = await UserService.get(int.parse(dataResult.message!));
      if (user != null) {
        await LocalDb.add(userKey, user.toJson());
        await UserService.getClaims();
      }
    } else {
      dataResult.success = false;
      dataResult.message = response.body;
    }
    return dataResult;
  }

  static Future<bool> logout() async {
    await LocalDb.delete(userClaimsKey);
    await LocalDb.delete(tokenModelKey);
    return true;
  }

  static Future<DataResult<TokenModel>?> changePassword(
      String oldPassword, String newPassword) async {
    var info = await LocalDb.get(userKey);
    var user = User.fromJson(info!);
    var uri = Uri.parse(
        "$url/changepassword?userId=${user.id}&oldPasword=$oldPassword&newPassword=$newPassword");
    var client = http.Client();
    var response = await client.post(uri);
    client.close();
    var dataResult = DataResult<TokenModel>();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      dataResult.data = TokenModel.fromJson(json.encode(result["data"]));
      dataResult.success = result["success"];
      dataResult.message = result["message"];

      await LocalDb.add(tokenModelKey, json.encode(result["data"]));
    } else {
      dataResult.success = false;
      dataResult.message = response.body;
    }
    return dataResult;
  }
}
