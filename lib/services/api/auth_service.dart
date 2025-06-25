import 'dart:convert';
import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/controllers/main/login_controller.dart';
import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/dtos/user_dto.dart';
import 'package:akilli_anahtar/models/login_model.dart';
import 'package:akilli_anahtar/models/login_model2.dart';
import 'package:akilli_anahtar/dtos/session_dto.dart';
import 'package:akilli_anahtar/models/old_session_model.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static String url = "$apiUrlOut/Auth";

  //remove
  static Future<SessionDto?> login(LoginModel loginModel) async {
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
        var session = SessionDto.fromJson(response.body);
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

  //remove
  static Future<void> login2(LoginModel2 loginModel) async {
    AuthController authController = Get.put(AuthController());
    authController.oldSessions.clear();
    print("$url/login2");
    print(loginModel.toJson());
    var uri = Uri.parse("$url/login2");
    var client = http.Client();
    try {
      var response = await client.post(
        uri,
        headers: {
          'content-type': 'application/json; charset=utf-8',
          'accept': '*/*'
        },
        body: loginModel.toJson(),
      );
      client.close();
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        LoginController loginController = Get.find();
        loginController.isLogin.value = true;
        var data = json.decode(response.body) as Map<String, dynamic>;
        var session = SessionDto.fromJson(json.encode(data["sessionDto"]));
        authController.session.value = session;
        var user = UserDto.fromJson(json.encode(data["userDto"]));
        authController.user.value = user;
        LocalDb.add(userNameKey, loginModel.userName);
        LocalDb.add(passwordKey, loginModel.password);
        return;
      } else if (response.statusCode == 202) {
        authController.oldSessions.value =
            OldSessionModel.fromJsonList(response.body);
        return;
      } else {
        errorSnackbar("Hata", response.body);
      }
    } catch (e) {
      errorSnackbar("Hata", "Oturum Açma Sırasında bir hata oluştu.");
      print(e);
    }
    return;
  }

  static Future<bool> appLogin(LoginModel2 loginModel) async {
    AuthController authController = Get.put(AuthController());
    authController.oldSessions.clear();
    print("$url/appLogin");
    print(loginModel.toJson());
    var uri = Uri.parse("$url/appLogin");
    var client = http.Client();
    try {
      var response = await client.post(
        uri,
        headers: {
          'content-type': 'application/json; charset=utf-8',
          'accept': '*/*'
        },
        body: loginModel.toJson(),
      );
      client.close();
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        LoginController loginController = Get.find();
        loginController.isLogin.value = true;
        var data = json.decode(response.body) as Map<String, dynamic>;

        var session = SessionDto.fromMap(data["sessionDto"]);
        print("Giriş sonrası oturum bilgisi: ${session.toMap()}");
        authController.session.value = session;

        var user = UserDto.fromMap(data["userDto"]);
        print("Giriş sonrası kullanıcı bilgisi: ${user.toMap()}");
        authController.user.value = user;
        print(
            "Giriş sonrası kullanıcı bilgisi: ${authController.user.value.toMap()}");
        authController.platformIdentity.value = loginModel.identity;

        LocalDb.add(userNameKey, loginModel.userName);
        LocalDb.add(passwordKey, loginModel.password);

        var alreadyAsked = await LocalDb.get(notificationPermissionKey);
        if (alreadyAsked != "true") {
          NotificationSettings settings =
              await FirebaseMessaging.instance.requestPermission();

          if (settings.authorizationStatus == AuthorizationStatus.authorized) {
            print(' Bildirim izni verildi.');
          } else if (settings.authorizationStatus ==
              AuthorizationStatus.denied) {
            print(' Bildirim izni reddedildi.');
          }

          await LocalDb.add(notificationPermissionKey, "true");
        }

        String? token = await FirebaseMessaging.instance.getToken();
        print("FCM TOKEN: $token");
        if (token != null) {
          await saveFcmToken(token);
        }

        await Future.delayed(Duration(milliseconds: 700));

        return true;
      } else if (response.statusCode == 202) {
        authController.oldSessions.value =
            OldSessionModel.fromJsonList(response.body);
        return false;
      } else {
        errorSnackbar("Hata", response.body);
        return false;
      }
    } catch (e) {
      print("appLogin hatası: $e");
      errorSnackbar("Hata", "Oturum Açma Sırasında bir hata oluştu.");
      return false;
    }
  }

  static Future<void> saveFcmToken(String token) async {
    final uri = Uri.parse("$url/save-fcm-token");
    final client = http.Client();

    final authController = Get.find<AuthController>();
    final accessToken = authController.session.value.accessToken;

    try {
      final response = await client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({"fcmToken": token}),
      );

      print("FCM token gönderildi. Durum: ${response.statusCode}");
    } catch (e) {
      print("FCM token gönderme hatası: $e");
    } finally {
      client.close();
    }
  }

  static Future<void> webLogin(LoginModel2 loginModel) async {
    print("$url/webLogin");
    print(loginModel.toJson());
    var uri = Uri.parse("$url/webLogin");
    var client = http.Client();
    try {
      var response = await client.post(
        uri,
        headers: {
          'content-type': 'application/json; charset=utf-8',
          'accept': '*/*'
        },
        body: loginModel.toJson(),
      );
      client.close();
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body) as Map<String, dynamic>;
        var session = SessionDto.fromJson(json.encode(data["sessionDto"]));
        var user = UserDto.fromJson(json.encode(data["userDto"]));
        await LocalDb.add(webTokenKey, session.accessToken);
        await LocalDb.add(userIdKey, user.id.toString());
        return;
      } else {
        errorSnackbar("Hata", response.body);
      }
    } catch (e) {
      errorSnackbar("Hata", "Oturum Açma Sırasında bir hata oluştu.");
      print(e);
    }
    return;
  }

  //remove
  // static Future<List<Device>?> getData() async {
  //   var authController = Get.find<AuthController>();
  //   HomeController homeController = Get.find();
  //   var response = await BaseService.get(
  //       "$url/getData?userId=${authController.user.value.id}");
  //   if (response.statusCode == 200) {
  //     var data = json.decode(response.body) as Map<String, dynamic>;
  //     // var claims = data["operationClaims"] != null
  //     //     ? OperationClaim.fromJsonList(json.encode(data["operationClaims"]))
  //     //     : <OperationClaim>[];
  //     // authController.operationClaims.value = claims;
  //     var parameters = Parameter.fromJsonList(json.encode(data["parameters"]));
  //     homeController.parameters.value = parameters;
  //     var organisations =
  //         Organisation.fromJsonList(json.encode(data["organisations"]));
  //     homeController.organisations.value = organisations;
  //     var devices = Device.fromJsonList(json.encode(data["devices"]));
  //     homeController.devices.value = devices;
  //     var cities = City.fromJsonList(json.encode(data["cities"]));
  //     homeController.cities.value = cities;
  //     var districts = District.fromJsonList(json.encode(data["districts"]));
  //     homeController.districts.value = districts;
  //     return devices;
  //   }
  //   return null;
  // }

  //remove
  static Future<List<OperationClaim>?> getUserClaims() async {
    var authController = Get.find<AuthController>();
    var response = await BaseService.get(
        "$url/getUserClaims?id=${authController.user.value.id}");
    if (response.statusCode == 200) {
      return OperationClaim.fromJsonList(response.body);
    }
    return null;
  }

  static Future<void> logOut(int sessionId, String identity) async {
    try {
      var uri =
          Uri.parse("$url/appLogout?sessionId=$sessionId&identity=$identity");
      var client = http.Client();
      var response = await client.put(
        uri,
        headers: {
          'content-type': 'application/json; charset=utf-8',
        },
      );
      client.close();
      print("$url/appLogout?sessionId=$sessionId&identity=$identity");
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        successSnackbar("Başarılı", response.body);
      } else {
        print("Oturum sonlandırma hatası: ${response.body}");
      }
    } catch (e) {
      print("logOut API hatası: $e");
    }
  }

  static Future<bool> changePassword(
      String oldPassword, String newPassword, String identity) async {
    var authController = Get.find<AuthController>();
    var session = authController.session.value;

    final uri = Uri.parse(
      "$url/changePassword"
      "?userId=${authController.user.value.id}"
      "&oldPasword=$oldPassword"
      "&newPassword=$newPassword"
      "&identity=${identity}",
    );

    var client = http.Client();

    try {
      var response = await client.put(
        uri,
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      if (response.statusCode == 200 && response.body.trim() == "true") {
        return true;
      }
      print("Şifre değiştir API status: ${response.statusCode}");
      print("Şifre değiştir API body: ${response.body}");
    } catch (e) {
      print("changePassword API hatası: $e");
    } finally {
      client.close();
    }

    return false;
  }
}
