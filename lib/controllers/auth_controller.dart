import 'dart:io';

import 'package:akilli_anahtar/controllers/home_controller.dart';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/entities/parameter.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/models/login_model.dart';
import 'package:akilli_anahtar/models/login_model2.dart';
import 'package:akilli_anahtar/models/token_model.dart';
import 'package:akilli_anahtar/pages/auth/login_page.dart';
import 'package:akilli_anahtar/services/api/auth_service.dart';
import 'package:akilli_anahtar/services/api/user_service.dart';
import 'package:akilli_anahtar/services/local/i_cache_manager.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/utils/hive_constants.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  var loginManager1 = CacheManager<LoginModel>(HiveConstants.loginModelKey,
      HiveConstants.loginModelTypeId, LoginModelAdapter());

  var loginManager2 = CacheManager<LoginModel2>(HiveConstants.loginModel2Key,
      HiveConstants.loginModel2TypeId, LoginModel2Adapter());

  var sessionManager = CacheManager<Session>(
      HiveConstants.sessionKey, HiveConstants.sessionTypeId, SessionAdapter());

  var loginModel2 = LoginModel2().obs;
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var isChanged = false.obs;
  var session = Session.epmty().obs;
  var user = User().obs;
  var operationClaims = <OperationClaim>[].obs;
  var parameters = <Parameter>[].obs;
  var organisations = <Organisation>[].obs;
  var devices = <Device>[].obs;

  // Future<void> loadToken() async {
  //   await sessionManager.init();
  //   var model = sessionManager.get();
  //   if (model != null) {
  //     session.value = model;
  //     isLoggedIn.value = true;
  //     await loadLoginInfo();
  //   }
  // }

  Future<void> loadLoginInfo() async {
    await loginManager2.init();
    var lm2 = loginManager2.get();
    if (lm2 == null) {
      await loginManager1.init();
      var lm = loginManager1.get();
      if (lm != null) {
        loginModel2.value.userName = lm.userName;
        loginModel2.value.password = lm.password;
        loginManager2.clear();
        loginManager2.add(loginModel2.value);
      }
      loginModel2.value.identity = await getDeviceId();
      loginModel2.value.platformName = await getDeviceName();
      return;
    } else {
      loginModel2.value = lm2;
    }
  }

  Future<void> login(LoginModel2 lm2) async {
    isLoggedIn.value = false;
    isLoading.value = true;
    session.value = Session.epmty();
    user.value = User();
    operationClaims.value = <OperationClaim>[];

    try {
      var loginResult = await AuthService.login2(lm2);
      if (loginResult != null) {
        successSnackbar('Başarılı', 'Oturum açıldı.');
        loginModel2.value = lm2;
        session.value = loginResult;
        await sessionManager.clear();
        await sessionManager.add(loginResult);
        await loginManager2.clear();
        await loginManager2.add(lm2);
        //await getUser();
        isLoggedIn.value = true;
      } else {
        errorSnackbar('Başarısız', 'Oturum açılamadı.');
      }
    } catch (e) {
      errorSnackbar('Hata', 'Giriş sırasında bir hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> getUser() async {
  //   var userResult =
  //       await UserService.getbyUserName(loginModel2.value.userName);
  //   if (userResult != null) {
  //     await userManager.clear();
  //     await userManager.add(userResult);
  //     user.value = userResult;
  //     var claims = await getUserClaims();
  //     if (claims != null) {
  //       operationClaims.value = claims;
  //     }
  //   }
  // }

  Future<List<OperationClaim>?> getUserClaims() async {
    var claimsResult = await AuthService.getUserClaims();
    if (claimsResult != null) {
      return claimsResult;
    }
    return null;
  }

  Future<void> logOut() async {
    await AuthService.logOut();
    isLoggedIn.value = false;
    session.value = Session.epmty();
    user.value = User();
    operationClaims.value = <OperationClaim>[];
    await sessionManager.clear();
    // await userManager.clear();
    // await claimsManager.clear();

    HomeController deviceController = Get.find();
    deviceController.clearController();
    Get.to(() => LoginPage());
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    isChanged.value = false;
    isLoading.value = true;
    try {
      var response = await AuthService.changePassword(oldPassword, newPassword);
      if (response != null) {
        session.value = response;
        isChanged.value = true;
        loginModel2.value.password = newPassword;
        await loginManager2.clear();
        loginManager2.add(loginModel2.value);
        await sessionManager.clear();
        sessionManager.add(session.value);
      }
    } catch (e) {
      errorSnackbar('Error', 'Bir hata oldu. Tekrar deneyin.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> getDeviceId() async {
    var info = DeviceInfoPlugin();
    String deviceId = "";
    if (Platform.isAndroid) {
      var androidInfo = await info.androidInfo;
      deviceId = androidInfo.id;
    }
    if (Platform.isIOS) {
      var iosInfo = await info.iosInfo;
      deviceId =
          iosInfo.identifierForVendor ?? "${iosInfo.name}-${iosInfo.model}";
    }
    return deviceId;
  }

  Future<String> getDeviceName() async {
    var info = DeviceInfoPlugin();
    String deviceName = "";
    if (Platform.isAndroid) {
      var androidInfo = await info.androidInfo;
      deviceName = "${androidInfo.brand} ${androidInfo.model}";
    }
    if (Platform.isIOS) {
      var iosInfo = await info.iosInfo;
      deviceName = "I Phone ${iosInfo.name}";
    }
    return deviceName;
  }
}
