import 'package:akilli_anahtar/models/login_model2.dart';
import 'package:akilli_anahtar/services/api/auth_service.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  var userName = "".obs;
  var password = "".obs;
  var privacyPolicy = true.obs;
  var deviceId = "".obs;
  var deviceName = "".obs;

  var userNameFocus = FocusNode();
  var passwordFocus = FocusNode();

  var isLogin = false.obs;

  Future<void> loadLoginInfo() async {
    deviceId.value = await getDeviceId();
    deviceName.value = await getDeviceName();
    userName.value = await LocalDb.get(userNameKey) ?? "";
    password.value = await LocalDb.get(passwordKey) ?? "";
  }

  Future<void> saveLoginInfo() async {
    LocalDb.add(userNameKey, userName.value);
    LocalDb.add(passwordKey, password.value);
  }

  Future<void> clearLoginInfo() async {
    await LocalDb.delete(webTokenKey);
    await LocalDb.delete(userIdKey);
    isLogin.value = false;

    print("Login info cleared successfully");
  }

  LoginModel2 get getLoginModel {
    return LoginModel2(
      userName: userName.value,
      password: password.value,
      identity: deviceId.value,
      platformName: deviceName.value,
    );
  }

  Future<bool> login() async {
    try {
      isLogin.value = false;
      final result = await AuthService.appLogin(getLoginModel);
      isLogin.value = result;
      if (result) {
        await saveLoginInfo();
      }
      return result;
    } catch (e) {
      print("Login hatası: $e");
      isLogin.value = false;
      return false;
    }
  }
}
