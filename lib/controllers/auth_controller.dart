import 'dart:io';

import 'package:akilli_anahtar/controllers/device_controller.dart';
import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/models/login_model.dart';
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
  var tokenManager = CacheManager<TokenModel>(HiveConstants.tokenModelKey,
      HiveConstants.tokenModelTypeId, TokenModelAdapter());

  var loginManager = CacheManager<LoginModel>(HiveConstants.loginModelKey,
      HiveConstants.loginModelTypeId, LoginModelAdapter());

  var claimsManager = CacheManager<OperationClaim>(HiveConstants.claimsKey,
      HiveConstants.claimsTypeId, OperationClaimAdapter());

  var userManager = CacheManager<User>(
      HiveConstants.userKey, HiveConstants.userTypeId, UserAdapter());

  var loginModel = LoginModel().obs;
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var isChanged = false.obs;
  var tokenModel = TokenModel.epmty().obs;
  var user = User().obs;
  var operationClaims = <OperationClaim>[].obs;

  Future<void> loadToken() async {
    await tokenManager.init();
    var model = tokenManager.get();
    if (model != null) {
      tokenModel.value = model;
      isLoggedIn.value = true;
      await loadLoginInfo();
    }
  }

  Future<void> loadLoginInfo() async {
    await loginManager.init();
    var lm = loginManager.get();
    if (lm != null) {
      loginModel.value = lm;
    }
  }

  Future<void> login(String userName, String password) async {
    isLoggedIn.value = false;
    isLoading.value = true;
    tokenModel.value = TokenModel.epmty();
    user.value = User();
    operationClaims.value = <OperationClaim>[];

    try {
      var lm = LoginModel(
        userName: userName,
        password: password,
      );
      var tokenResult = await AuthService.login(lm);
      if (tokenResult != null) {
        successSnackbar('Başarılı', 'Oturum açıldı.');
        loginModel.value = lm;
        tokenModel.value = tokenResult;
        await tokenManager.clear();
        await tokenManager.add(tokenResult);
        await loginManager.clear();
        await loginManager.add(lm);
        await getUser();
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

  Future<void> getUser() async {
    var userResult = await UserService.getbyUserName(loginModel.value.userName);
    if (userResult != null) {
      await userManager.clear();
      await userManager.add(userResult);
      user.value = userResult;
      var claims = await getUserClaims();
      if (claims != null) {
        operationClaims.value = claims;
      }
    }
  }

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
    tokenModel.value = TokenModel.epmty();
    user.value = User();
    operationClaims.value = <OperationClaim>[];
    await tokenManager.clear();
    await userManager.clear();
    await claimsManager.clear();

    DeviceController deviceController = Get.find();
    deviceController.clearController();
    Get.to(() => LoginPage());
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    isChanged.value = false;
    isLoading.value = true;
    try {
      var response = await AuthService.changePassword(oldPassword, newPassword);
      if (response != null) {
        tokenModel.value = response;
        isChanged.value = true;
        loginModel.value.password = newPassword;
        await loginManager.clear();
        loginManager.add(loginModel.value);
        await tokenManager.clear();
        tokenManager.add(tokenModel.value);
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
}
