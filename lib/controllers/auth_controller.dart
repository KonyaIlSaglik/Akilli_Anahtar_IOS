import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/models/login_model.dart';
import 'package:akilli_anahtar/models/register_model.dart';
import 'package:akilli_anahtar/models/token_model.dart';
import 'package:akilli_anahtar/pages/login_page2.dart';
import 'package:akilli_anahtar/services/api/auth_service.dart';
import 'package:akilli_anahtar/services/api/operation_claim_service.dart';
import 'package:akilli_anahtar/services/api/user_service.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  var loginModel = LoginModel().obs;
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var isChanged = false.obs;
  var tokenModel = TokenModel.epmty().obs;
  var user = User().obs;
  var operationClaims = <OperationClaim>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAuth();
  }

  Future<void> login(String userName, String password) async {
    isLoggedIn.value = false;
    isLoading.value = true;
    tokenModel.value = TokenModel.epmty();
    user.value = User();
    operationClaims.value = <OperationClaim>[];
    await LocalDb.delete(tokenModelKey);
    await LocalDb.delete(userClaimsKey);
    await LocalDb.delete(userKey);
    try {
      var lm = LoginModel(
        userName: userName,
        password: password,
      );
      var tokenResult = await AuthService.login(lm);
      if (tokenResult != null) {
        loginModel.value = lm;
        tokenModel.value = tokenResult;
        await LocalDb.add(loginModelKey, loginModel.toJson());
        await LocalDb.add(tokenModelKey, tokenModel.value.toJson());
        await getUser();
        await getClaims();
        isLoggedIn.value = true;
      }
    } catch (e) {
      Get.snackbar('Error', 'Bir hata oldu. Tekrar deneyin.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getUser() async {
    var userResult = await UserService.getbyUserName(loginModel.value.userName);
    if (userResult != null) {
      LocalDb.add(userKey, userResult.toJson());
      user.value = userResult;
    }
  }

  Future<void> getClaims() async {
    if (user.value.id > 0) {
      var claimsResult = await OperationClaimService.getClaims(user.value);
      if (claimsResult.success) {
        operationClaims.value = claimsResult.data!;
        LocalDb.add(userClaimsKey, OperationClaim.toJsonList(operationClaims));
      }
    }
  }

  Future<void> logOut() async {
    await AuthService.logOut();
    isLoggedIn.value = false;
    tokenModel.value = TokenModel.epmty();
    user.value = User();
    operationClaims.value = <OperationClaim>[];
    await LocalDb.delete(tokenModelKey);
    await LocalDb.delete(userClaimsKey);
    await LocalDb.delete(userKey);
    Get.to(() => LoginPage2());
  }

  Future<void> register(RegisterModel registerModel) async {
    isLoggedIn.value = false;
    isLoading.value = true;
    try {
      var response = await AuthService.register(registerModel);
      if (response.success) {
        tokenModel.value = response.data!;
        isLoggedIn.value = true;
        loginModel.value.userName = registerModel.userName;
        loginModel.value.password = registerModel.password;
        await LocalDb.add(loginModelKey, loginModel.toJson());
        await LocalDb.add(tokenModelKey, tokenModel.value.toJson());
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
        loginModel.value.password = newPassword;
        await LocalDb.add(loginModelKey, loginModel.toJson());
        await LocalDb.add(tokenModelKey, tokenModel.value.toJson());
      }
    } catch (e) {
      Get.snackbar('Error', 'Bir hata oldu. Tekrar deneyin.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAuth() async {
    var savedLoginModel = await LocalDb.get(loginModelKey);
    if (savedLoginModel != null) {
      loginModel.value = LoginModel.fromJson(savedLoginModel);
    } else {
      isLoggedIn.value = false;
      Get.to(() => LoginPage2());
    }
    var savedUser = await LocalDb.get(userKey);
    if (savedUser != null) {
      user.value = User.fromJson(savedUser);
    }

    final savedToken = await LocalDb.get(tokenModelKey);
    if (savedToken != null) {
      tokenModel.value = TokenModel.fromJson(savedToken);
      DateTime tokenExpiryDate = DateTime.parse(tokenModel.value.expiration);
      bool isTokenExpired = DateTime.now().isAfter(tokenExpiryDate);
      if (isTokenExpired) {
        await login(loginModel.value.userName, loginModel.value.password);
      } else {
        isLoggedIn.value = true;
      }
    } else {
      isLoggedIn.value = false;
      Get.to(() => LoginPage2());
    }
    await getUser();
    await getClaims();
  }
}
