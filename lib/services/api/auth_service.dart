import 'dart:convert';
import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/controllers/home_controller.dart';
import 'package:akilli_anahtar/controllers/login_controller.dart';
import 'package:akilli_anahtar/entities/city.dart';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/entities/district.dart';
import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/entities/parameter.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/models/login_model.dart';
import 'package:akilli_anahtar/models/login_model2.dart';
import 'package:akilli_anahtar/models/session_model.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static String url = "$apiUrlOut/Auth";

  static Future<Session?> login(LoginModel loginModel) async {
    loginModel.identity = await getDeviceId();
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
        var session = Session.fromJson(response.body);
        return session;
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

  static Future<void> login2(LoginModel2 loginModel) async {
    AuthController authController = Get.put(AuthController());
    print("$url/login2");
    print(loginModel.toJson());
    var uri = Uri.parse("$url/login2");
    var client = http.Client();
    try {
      var response = await client
          .post(
            uri,
            headers: {
              'content-type': 'application/json; charset=utf-8',
            },
            body: loginModel.toJson(),
          )
          .timeout(Duration(seconds: 15));
      client.close();
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        LoginController loginController = Get.find();
        loginController.isLogin.value = true;
        var data = json.decode(response.body) as Map<String, dynamic>;
        var session = Session.fromJson(json.encode(data["session"]));
        authController.session.value = session;
        var user = User.fromJson(json.encode(data["userDto"]));
        authController.user.value = user;
        return;
      }
      if (response.statusCode == 404) {
        print(response.body);
        authController.allSessions.value = Session.fromJsonList(response.body);
        return;
      }
      if (response.statusCode == 400) {
        errorSnackbar("Hata", response.body);
      }
    } catch (e) {
      errorSnackbar("Hata", "Oturum Açma Sırasında bir hata oluştu.");
      print(e);
    }
    return;
  }

  static Future<void> getData() async {
    var authController = Get.find<AuthController>();
    HomeController homeController = Get.find();
    var response = await BaseService.get(
        "$url/getData?userId=${authController.user.value.id}");
    if (response.statusCode == 200) {
      var data = json.decode(response.body) as Map<String, dynamic>;
      var claims =
          OperationClaim.fromJsonList(json.encode(data["operationClaims"]));
      authController.operationClaims.value = claims;
      var parameters = Parameter.fromJsonList(json.encode(data["parameters"]));
      homeController.parameters.value = parameters;
      print(json.encode(data["organisations"]));
      var organisations =
          Organisation.fromJsonList(json.encode(data["organisations"]));
      homeController.organisations.value = organisations;
      var devices = Device.fromJsonList(json.encode(data["devices"]));
      homeController.devices.value = devices;
      var cities = City.fromJsonList(json.encode(data["cities"]));
      homeController.cities.value = cities;
      var districts = District.fromJsonList(json.encode(data["districts"]));
      homeController.districts.value = districts;
    }
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

  static Future<void> logOut(int userId, String identity) async {
    var uri = Uri.parse("$url/logout?userId=$userId&identity=$identity");
    var client = http.Client();
    var response = await client.put(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
      },
    );
    client.close();
    print("$url/logout?userId=$userId&identity=$identity");
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      successSnackbar("Başarılı", response.body);
    } else {
      errorSnackbar("Hata", response.body);
    }
  }

  static Future<Session?> changePassword(
      String oldPassword, String newPassword) async {
    var authController = Get.find<AuthController>();
    var session = authController.session.value;
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
        'Authorization': 'Bearer ${session.accessToken}',
      },
      body: json.encode(requestBody),
    );
    client.close();
    if (response.statusCode == 200) {
      var data = Session.fromJson(json.encode(response.body));
      return data;
    }
    return null;
  }
}
