import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/models/login_model.dart';
import 'package:akilli_anahtar/models/register_model.dart';
import 'package:akilli_anahtar/models/token_model.dart';
import 'package:akilli_anahtar/pages/login_page2.dart';
import 'package:akilli_anahtar/services/api/auth_service.dart';
import 'package:akilli_anahtar/services/api/operation_claim_service.dart';
import 'package:akilli_anahtar/services/api/user_service.dart';
import 'package:akilli_anahtar/services/local/i_cache_manager.dart';
import 'package:akilli_anahtar/utils/hive_constants.dart';
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

  @override
  void onInit() async {
    super.onInit();
  }

  Future<void> loadToken() async {
    await loginManager.init();
    var lm = loginManager.get();
    if (lm != null) {
      loginModel.value = lm;
    } else {
      Get.to(() => LoginPage2());
      return;
    }

    await userManager.init();
    var usr = userManager.get();
    if (usr != null) {
      user.value = usr;
    } else {
      await getUser();
    }

    await claimsManager.init();
    var claims = claimsManager.getAll();
    if (claims!.isNotEmpty) {
      operationClaims.value = claims;
    } else {
      await getClaims();
    }

    await tokenManager.init();
    var model = tokenManager.get();
    if (model != null) {
      tokenModel.value = model;
      isLoggedIn.value = true;
    } else {
      Get.to(() => LoginPage2());
      return;
    }
  }

  Future<void> login(String userName, String password) async {
    isLoggedIn.value = false;
    isLoading.value = true;
    tokenModel.value = TokenModel.epmty();
    user.value = User();
    operationClaims.value = <OperationClaim>[];

    tokenManager.clear();
    loginManager.clear();

    try {
      var lm = LoginModel(
        userName: userName,
        password: password,
      );
      var tokenResult = await AuthService.login(lm);
      if (tokenResult != null) {
        Get.snackbar('Info', 'Giriş başarılı.');
        loginModel.value = lm;
        tokenModel.value = tokenResult;
        tokenManager.add(tokenResult);
        loginManager.add(lm);
        await getUser();
        await getClaims();
        isLoggedIn.value = true;
      } else {
        Get.snackbar('Error', 'Giriş Başarısız.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Giriş sırasında bir hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getUser() async {
    var userResult = await UserService.getbyUserName(loginModel.value.userName);
    if (userResult != null) {
      userManager.add(userResult);
      user.value = userResult;
    }
  }

  Future<void> getClaims() async {
    if (user.value.id > 0) {
      var claimsResult = await OperationClaimService.getClaims(user.value);
      if (claimsResult.success) {
        operationClaims.value = claimsResult.data!;
        claimsManager.addList(claimsResult.data!);
      }
    }
  }

  Future<void> logOut() async {
    await AuthService.logOut();
    isLoggedIn.value = false;
    tokenModel.value = TokenModel.epmty();
    user.value = User();
    operationClaims.value = <OperationClaim>[];
    tokenManager.clear();
    userManager.clear();
    claimsManager.clear();
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
        // await LocalDb.add(loginModelKey, loginModel.toJson());
        // await LocalDb.add(tokenModelKey, tokenModel.value.toJson());
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
        await loginManager.clear();
        loginManager.add(loginModel.value);
        await tokenManager.clear();
        tokenManager.add(tokenModel.value);
      }
    } catch (e) {
      Get.snackbar('Error', 'Bir hata oldu. Tekrar deneyin.');
    } finally {
      isLoading.value = false;
    }
  }
}
