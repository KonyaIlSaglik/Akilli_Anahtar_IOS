import 'package:akilli_anahtar/controllers/user_controller.dart';
import 'package:akilli_anahtar/models/login_model.dart';
import 'package:akilli_anahtar/models/register_model.dart';
import 'package:akilli_anahtar/models/token_model.dart';
import 'package:akilli_anahtar/pages/login_page2.dart';
import 'package:akilli_anahtar/services/api/auth_service.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var isChanged = false.obs;
  var tokenModel = TokenModel().obs;

  @override
  void onInit() {
    super.onInit();
    loadToken();
  }

  Future<void> login(String userName, String password) async {
    isLoggedIn.value = false;
    isLoading.value = true;
    try {
      var response = await AuthService.login(
        LoginModel(
          userName: userName,
          password: password,
        ),
      );
      if (response.success) {
        tokenModel.value = response.data!;
        isLoggedIn.value = true;
        saveToken();
        await LocalDb.add(userNameKey, userName);
        await LocalDb.add(passwordKey, password);
        await Get.put(UserController()).getUser();
      }
    } catch (e) {
      Get.snackbar('Error', 'Bir hata oldu. Tekrar deneyin.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(RegisterModel registerModel) async {
    isLoggedIn.value = false;
    isLoading.value = true;
    try {
      var response = await AuthService.register(registerModel);
      if (response.success) {
        tokenModel.value = response.data!;
        isLoggedIn.value = true;
        saveToken();
        await LocalDb.add(userNameKey, registerModel.userName);
        await LocalDb.add(passwordKey, registerModel.password);
        await Get.put(UserController()).getUser();
      }
    } catch (e) {
      Get.snackbar('Error', 'Bir hata oldu. Tekrar deneyin.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    isChanged.value = false;
    isLoading.value = true;
    try {
      var response = await AuthService.changePassword(oldPassword, newPassword);
      if (response.success) {
        tokenModel.value = response.data!;
        isChanged.value = true;
        saveToken();
        await LocalDb.add(passwordKey, newPassword);
        await Get.put(UserController()).getUser();
        await Get.put(UserController()).getPassword();
      }
    } catch (e) {
      Get.snackbar('Error', 'Bir hata oldu. Tekrar deneyin.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveToken() async {
    await LocalDb.add(tokenModelKey, tokenModel.value.toJson());
  }

  Future<void> removeToken() async {
    await LocalDb.delete(tokenModelKey);
  }

  Future<void> loadToken() async {
    final savedToken = await LocalDb.get(tokenModelKey);
    if (savedToken != null) {
      tokenModel.value = TokenModel.fromJson(savedToken);
      DateTime tokenExpiryDate = DateTime.parse(tokenModel.value.expiration);
      bool isTokenExpired = DateTime.now().isAfter(tokenExpiryDate);
      if (isTokenExpired) {
        var userName = await LocalDb.get(userNameKey);
        var password = await LocalDb.get(passwordKey);
        if (userName != null && password != null) {
          await login(userName, password);
          isLoggedIn.value = true;
        } else {
          isLoggedIn.value = false;
          Get.snackbar("Hata", "Oturum Açılamadı. Tekrar giriş yapın.");
          Get.to(LoginPage2());
        }
      } else {
        isLoggedIn.value = true;
      }
    } else {
      isLoggedIn.value = false;
      Get.to(LoginPage2());
    }
  }
}
