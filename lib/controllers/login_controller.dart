import 'package:akilli_anahtar/models/login_model.dart';
import 'package:akilli_anahtar/models/login_model2.dart';
import 'package:akilli_anahtar/services/api/auth_service.dart';
import 'package:akilli_anahtar/services/local/i_cache_manager.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/utils/hive_constants.dart';
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
    var loginManagerNew = CacheManager(HiveConstants.loginModel2Key,
        HiveConstants.loginModel2TypeId, LoginModel2Adapter());

    await loginManagerNew.init();
    var lm2 = loginManagerNew.get();
    if (lm2 == null) {
      var loginManagerOld = CacheManager(HiveConstants.loginModelKey,
          HiveConstants.loginModelTypeId, LoginModelAdapter());
      await loginManagerOld.init();
      var lm = loginManagerOld.get();
      if (lm != null) {
        userName.value = lm.userName;
        password.value = lm.password;
        await saveLoginInfo();
      }
      return;
    } else {
      userName.value = lm2.userName;
      password.value = lm2.password;
    }
  }

  Future<void> saveLoginInfo() async {
    var loginManagerNew = CacheManager(HiveConstants.loginModel2Key,
        HiveConstants.loginModel2TypeId, LoginModel2Adapter());
    await loginManagerNew.clear();
    await loginManagerNew.add(getLoginModel);
  }

  Future<void> clearLoginInfo() async {
    var loginManagerNew = CacheManager(HiveConstants.loginModel2Key,
        HiveConstants.loginModel2TypeId, LoginModel2Adapter());
    await loginManagerNew.clear();
    password.value = "";
    await loginManagerNew.add(getLoginModel);
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
