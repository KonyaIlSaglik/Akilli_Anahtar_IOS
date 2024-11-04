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
    await LocalDb.delete(passwordKey);
  }

  LoginModel2 get getLoginModel {
    return LoginModel2(
      userName: userName.value,
      password: password.value,
      identity: deviceId.value,
      platformName: deviceName.value,
    );
  }

  Future<void> login() async {
    await AuthService.login2(getLoginModel);
    if (isLogin.value) {
      saveLoginInfo();
    }
  }
}
