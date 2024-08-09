import 'package:akilli_anahtar/models/login_model.dart';
import 'package:akilli_anahtar/models/token_model.dart';
import 'package:akilli_anahtar/services/api/auth_service.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var tokenModel = TokenModel().obs;

  @override
  void onInit() {
    super.onInit();
    loadToken();
  }

  Future<void> login(String userName, String password) async {
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
        _saveToken();
        await LocalDb.add(userNameKey, userName);
        await LocalDb.add(passwordKey, password);
      }
    } catch (e) {
      Get.snackbar('Error', 'Bir hata oldu. Tekrar deneyin.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveToken() async {
    await LocalDb.add(tokenModelKey, tokenModel.value.toJson());
  }

  Future<void> _removeToken() async {
    await LocalDb.delete(tokenModelKey);
  }

  Future<void> loadToken() async {
    final savedToken = await LocalDb.get(tokenModelKey);
    if (savedToken != null) {
      tokenModel.value = TokenModel.fromJson(savedToken);
      isLoggedIn.value = true;
    } else {
      isLoggedIn.value = false;
    }
  }
}
