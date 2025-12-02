import 'dart:convert';
import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/login_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/dtos/complete_register_user_dto.dart';
import 'package:akilli_anahtar/dtos/update_google_user_dto.dart';
import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/dtos/user_dto.dart';
import 'package:akilli_anahtar/main.dart';
import 'package:akilli_anahtar/models/login_model.dart';
import 'package:akilli_anahtar/models/login_model2.dart';
import 'package:akilli_anahtar/dtos/session_dto.dart';
import 'package:akilli_anahtar/models/old_session_model.dart';
import 'package:akilli_anahtar/pages/managers/user/complete_profile_page.dart';
import 'package:akilli_anahtar/pages/managers/user/update_social_user.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  static String url = "$apiUrlOut/Auth";
  static String userUrl = "$apiUrlOut/User";

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

  static Future<bool> registerUser({
    required String fullName,
    required String mail,
    required String userName,
    required String telephone,
    required String password,
    required String identity,
    required String platformName,
  }) async {
    try {
      final uri = Uri.parse('$url/register');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          "userName": mail,
          "fullName": fullName,
          "mail": mail,
          "telephone": telephone,
          "password": password,
          "identity": await getDeviceId(),
          "platformName": platformName,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        final sessionDto = jsonResponse["sessionDto"];
        final userDto = jsonResponse["userDto"];

        final AuthController authController = Get.find();
        authController.session.value = SessionDto.fromMap(sessionDto);
        authController.user.value = UserDto.fromMap(userDto);

        await authController.fetchAndAssignUserRoles();

        return true;
      } else {
        String errorMessage = response.body;
        print("Kayıt başarısız");
        errorSnackbar("Hata", "");
        return false;
      }
    } catch (e) {
      print("Register error: $e");
      return false;
    }
  }

  static Future<int> sendEmailVerificationCode(int userId, String email) async {
    var uri = Uri.parse("$url/sendEmailVerificationCode");
    var client = http.Client();
    try {
      var response = await client.post(
        uri,
        headers: {'content-type': 'application/json'},
        body: json.encode({"userId": userId, "email": email}),
      );
      client.close();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse["userId"];
      } else if (response.statusCode == 409) {
        throw Exception("email_conflict");
      } else {
        throw Exception("Sunucu hatası: ${response.body}");
      }
    } catch (e) {
      print("E-posta kaydı hatası: $e");
      rethrow;
    }
  }

  static Future<bool> resendVerifyCode(int userId) async {
    final uri = Uri.parse("$url/resendEmailCode");
    final client = http.Client();

    try {
      final response = await client.post(
        uri,
        headers: {'content-type': 'application/json'},
        body: json.encode({"userId": userId}),
      );

      if (response.statusCode == 200) {
        final message = jsonDecode(response.body)['message'];
        print("Başarılı: $message");
        return true;
      } else {
        final error = jsonDecode(response.body)['error'];
        print("Hata: $error");
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      client.close();
    }
  }

  static Future<bool> completeRegisterUser(CompleteRegisterUserDto dto) async {
    final uri = Uri.parse("$url/completeRegisterUser");
    var client = http.Client();
    try {
      var response = await client.post(
        uri,
        headers: {'content-type': 'application/json'},
        body: json.encode(dto.toJson()),
      );
      client.close();

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Profil tamamlama hatası: ${response.body}");
        return false;
      }
    } catch (e) {
      print("completeRegisterUser hatası: $e");
      return false;
    }
  }

  static Future<UserDto?> verifyCode(int userId, String code) async {
    var uri = Uri.parse("$userUrl/verifyEmailCode");
    var client = http.Client();
    print("Gönderilen userId: $userId, code: $code");
    var response = await client.post(
      uri,
      headers: {'content-type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'code': code,
      }),
    );
    print("API response: ${response.body}");
    client.close();

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final userMap = data["user"] as Map<String, dynamic>;
      return UserDto.fromMap(userMap);
    }
    if (response.statusCode == 400) {
      print("Doğrulama kodu hatalı: ${response.body}");
      return null;
    } else {
      print("Beklenmeyen durum: ${response.body}");
      return null;
    }
  }

  static Future<bool> completeProfile(UpdateGoogleUserDto dto) async {
    try {
      final authController = Get.find<AuthController>();

      final response = await http.put(
        Uri.parse("$userUrl/updateSocialUser"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.session.value.accessToken}',
        },
        body: json.encode(dto.toJson()),
      );
      print("Gönderilen DTO: ${dto.toJson()}");

      if (response.statusCode == 200) {
        final updatedUser = UserDto.fromJson(response.body);

        authController.user.value = updatedUser;
        return true;
      } else {
        print("Profil tamamlama hatası: ${response.body}");
        print("Profil güncelleme statusCode: ${response.statusCode}");

        return false;
      }
    } catch (e) {
      print("completeGoogleProfileDto hatası: $e");
      return false;
    }
  }

  static Future<bool> sendResetPasswordEmail(String email) async {
    final uri = Uri.parse("$url/sendResetPasswordLink");
    final client = http.Client();

    try {
      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"email": email}),
      );

      if (response.statusCode == 200) {
        print("Şifre sıfırlama e-postası gönderildi: ${response.body}");
        successSnackbar("Başarılı",
            "Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.Postanızı kontrol edin.");
        return true;
      } else {
        print("Şifre sıfırlama e-postası gönderilemedi: ${response.body}");
        return false;
      }
    } catch (e) {
      print("sendResetPasswordEmail hatası: $e");
      return false;
    } finally {
      client.close();
    }
  }

  static Future<bool> loginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      print("Google ID Token: $idToken");

      if (idToken == null ||
          !idToken.contains('.') ||
          idToken.split('.').length != 3) {
        print("Geçersiz Google ID Token: $idToken");
        return false;
      }

      final response = await http.post(
        Uri.parse("$url/googleLogin"),
        headers: {'Content-Type': 'application/json', 'accept': '*/*'},
        body: json.encode({
          'idToken': idToken,
          'identity': await getDeviceId(),
        }),
      );

      final authController = Get.put(AuthController());

      if (response.statusCode == 409) {
        errorSnackbar("Hata",
            "Bu e-posta ile kayıtlı bir hesap var. Şifreyle giriş yapın.");
        return false;
      }

      if (response.statusCode == 202) {
        final data = json.decode(response.body) as List<dynamic>;
        final sessions = data.map((e) => OldSessionModel.fromMap(e)).toList();

        authController.oldSessions.assignAll(sessions);

        await authController.checkSessions(Get.context!);
        return false;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        final session = SessionDto.fromMap(data["sessionDto"]);
        final user = UserDto.fromMap(data["userDto"]);
        final isNewUser = data["isNewUser"] == true;

        await authController.fetchAndAssignUserRoles();

        authController.session.value = session;
        authController.user.value = user;

        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) await saveFcmToken(token);

        if (isNewUser || !user.isSocialProfileComplete) {
          Get.offAll(() => const CompleteProfilePage());
        } else {
          Get.offAllNamed('/layout');
        }

        return true;
      } else {
        errorSnackbar("Hata", "Google ile giriş başarısız");
        print("response.body type: ${response.body.runtimeType}");
        return false;
      }
    } catch (e) {
      errorSnackbar("Google giriş hatası", "Beklenmeyen bir hata oluştu");
      print("Google giriş hatası: $e");
      return false;
    }
  }

  static Future<bool> tryAutoGoogleLogin() async {
    try {
      final googleUser = await GoogleSignIn().signInSilently();
      print("Google user: ${googleUser?.email}");

      if (googleUser == null) {
        print("Sessiz Google oturum bulunamadı.");
        return false;
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) return false;

      final idToken = googleAuth.idToken!;
      final response = await http.post(
        Uri.parse("$url/googleLogin"),
        headers: {'Content-Type': 'application/json', 'accept': '*/*'},
        body: json.encode({
          'idToken': idToken,
          'identity': await getDeviceId(),
        }),
      );

      if (response.statusCode == 202) {
        final data = json.decode(response.body) as List<dynamic>;
        final sessions = data.map((e) => OldSessionModel.fromMap(e)).toList();

        AuthController authController = Get.put(AuthController());
        authController.oldSessions.assignAll(sessions);
        return false;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        final session = SessionDto.fromJson(json.encode(data["sessionDto"]));
        final user = UserDto.fromJson(json.encode(data["userDto"]));

        AuthController authController = Get.put(AuthController());
        authController.session.value = session;
        authController.user.value = user;

        await authController.fetchAndAssignUserRoles();

        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) await saveFcmToken(token);

        if (!user.isSocialProfileComplete) {
          Get.offAll(() => const CompleteProfilePage());
          return false;
        }

        print("Google ile otomatik giriş başarılı");
        Get.offAllNamed('/layout');
        return true;
      } else {
        print("Google ile otomatik giriş başarısız: ${response.body}");
        return false;
      }
    } catch (e) {
      print("tryAutoGoogleLogin hatası: $e");
      return false;
    }
  }

  static Future<bool> loginWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.akillianahtar',
          redirectUri: Uri.parse('https://example.com/callback'),
        ),
      );

      final idToken = credential.identityToken;
      final sub = credential.userIdentifier;

      if (sub == null) {
        errorSnackbar("Apple Girişi", "Apple ID alınamadı.");
        return false;
      }

      await LocalDb.add(appleUserKey, sub);

      print(
          "Apple Credential: $credential || Email: ${credential.email} || authorizationCode: ${credential.authorizationCode}");

      if (idToken == null ||
          !idToken.contains('.') ||
          idToken.split('.').length != 3) {
        errorSnackbar("Apple Girişi", "Geçersiz Apple ID Token.");
        return false;
      }

      print("Apple ID Token: $idToken");

      final response = await http.post(
        Uri.parse("$url/appleLogin"),
        headers: {'Content-Type': 'application/json', 'accept': '*/*'},
        body: json.encode({
          'idToken': idToken,
          'identity': await getDeviceId(),
        }),
      );

      final authController = Get.put(AuthController());

      if (response.statusCode == 409) {
        errorSnackbar("Hata",
            "Bu e-posta ile bir hesap zaten var. Şifreyle giriş yapın.");
        return false;
      }

      if (response.statusCode == 202) {
        final data = json.decode(response.body) as List<dynamic>;
        final sessions = data.map((e) => OldSessionModel.fromMap(e)).toList();
        authController.oldSessions.assignAll(sessions);
        await authController.checkSessions(Get.context!);
        return false;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final session = SessionDto.fromMap(data["sessionDto"]);
        final user = UserDto.fromMap(data["userDto"]);
        final isNewUser = data["isNewUser"] == true;

        authController.session.value = session;
        authController.user.value = user;

        await authController.fetchAndAssignUserRoles();

        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) await saveFcmToken(token);

        if (isNewUser || !user.isSocialProfileComplete) {
          Get.offAll(() => const SocialUserUpdatePage());
        } else {
          Get.offAllNamed('/layout');
        }

        return true;
      } else {
        errorSnackbar("Hata", "Apple ile giriş başarısız: ${response.body}");
        return false;
      }
    } catch (e) {
      errorSnackbar("Apple Girişi", "Beklenmeyen hata oluştu: $e");
      print("Apple login hatası: $e");
      return false;
    }
  }

  static Future<bool> tryAutoAppleLogin() async {
    try {
      final appleId = await LocalDb.get(appleUserKey);
      if (appleId == null) return false;

      final credentialState = await SignInWithApple.getCredentialState(appleId);

      if (credentialState != CredentialState.authorized) {
        print("Apple kimliği geçersiz: $credentialState");
        return false;
      }

      final identity = await getDeviceId();

      final response = await http.post(
        Uri.parse("$url/appleSilentLogin"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "appleId": appleId,
          "identity": identity,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final session = SessionDto.fromMap(data["sessionDto"]);
        final user = UserDto.fromMap(data["userDto"]);

        final controller = Get.put(AuthController());
        controller.session.value = session;
        controller.user.value = user;

        await controller.fetchAndAssignUserRoles();

        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) await saveFcmToken(token);

        if (!user.isSocialProfileComplete) {
          Get.offAll(() => const SocialUserUpdatePage());
          return false;
        }

        Get.offAllNamed('/layout');
        return true;
      }

      print("Sessiz Apple login başarısız: ${response.body}");
      return false;
    } catch (e) {
      print("tryAutoAppleLogin hatası: $e");
      return false;
    }
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
        authController.session.value = session;
        print("Giriş sonrası oturum bilgisi: ${session.toMap()}");

        var user = UserDto.fromMap(data["userDto"]);
        authController.user.value = user;
        print("Giriş sonrası kullanıcı bilgisi: ${user.toMap()}");

        await authController.fetchAndAssignUserRoles();

        LocalDb.add(userNameKey, loginModel.userName);
        LocalDb.add(passwordKey, loginModel.password);

        //await saveTokenToNative(session.accessToken);

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
        errorSnackbar("Hata", "");
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
        MqttController mqttController = Get.find<MqttController>();
        mqttController.client.disconnect();
        HomeController homeController = Get.find<HomeController>();
        homeController.hardReset();
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
