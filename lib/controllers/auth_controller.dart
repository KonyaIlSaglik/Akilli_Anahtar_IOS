import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/models/login_model.dart';
import 'package:akilli_anahtar/models/login_model2.dart';
import 'package:akilli_anahtar/models/session_model.dart';
import 'package:akilli_anahtar/pages/auth/login_page.dart';
import 'package:akilli_anahtar/services/api/auth_service.dart';
import 'package:akilli_anahtar/services/local/i_cache_manager.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/utils/hive_constants.dart';
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
  var session = Session.empty().obs;
  var allSessions = <Session>[].obs;
  var user = User().obs;
  var operationClaims = <OperationClaim>[].obs;

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
      if (lm2.identity.isEmpty) {
        loginModel2.value.identity = await getDeviceId();
        loginModel2.value.platformName = await getDeviceName();
      }
    }
  }

  Future<void> login() async {
    isLoggedIn.value = false;
    isLoading.value = true;
    session.value = Session.empty();
    user.value = User();
    operationClaims.value = <OperationClaim>[];
    try {
      await AuthService.login2(loginModel2.value);
      print("object");
      if (session.value.accessToken.isNotEmpty) {
        await sessionManager.clear();
        await sessionManager.add(session.value);
        await loginManager2.clear();
        await loginManager2.add(loginModel2.value);
        isLoggedIn.value = true;
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

  Future<void> logOut(int userId, String identity) async {
    await AuthService.logOut(userId, identity);
    isLoggedIn.value = false;
    session.value = Session.empty();
    user.value = User();
    operationClaims.value = <OperationClaim>[];
    await sessionManager.clear();
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
}
