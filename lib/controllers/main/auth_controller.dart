import 'package:akilli_anahtar/background_service.dart';
import 'package:akilli_anahtar/controllers/main/login_controller.dart';
import 'package:akilli_anahtar/dtos/complete_register_user_dto.dart';
import 'package:akilli_anahtar/dtos/device_user_role_dto.dart';
import 'package:akilli_anahtar/dtos/update_google_user_dto.dart';
import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/dtos/user_dto.dart';
import 'package:akilli_anahtar/dtos/session_dto.dart';
import 'package:akilli_anahtar/models/old_session_model.dart';
import 'package:akilli_anahtar/pages/auth/login_page.dart';
import 'package:akilli_anahtar/services/api/management_service.dart';
import 'package:akilli_anahtar/services/api/user_service.dart';
import 'package:akilli_anahtar/splash_page.dart';
import 'package:akilli_anahtar/services/api/auth_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  var session = SessionDto.empty().obs;
  var oldSessions = <OldSessionModel>[].obs;
  var user = UserDto().obs;
  var isLoading = false.obs;
  var isChanged = false.obs;
  var platformIdentity = "".obs;
  var platformName = "".obs;
  final RxList<DeviceRoleDto> deviceRoles = <DeviceRoleDto>[].obs;
  final RxList<int> adminDeviceIds = <int>[].obs;
  final isAdmin = false.obs;

  Future<void> fetchAndAssignUserRoles() async {
    try {
      final roles = await ManagementService.getUserDevices();
      deviceRoles.assignAll(roles);
      adminDeviceIds.assignAll(
        roles.where((e) => e.role == "admin").map((e) => e.deviceId),
      );
      for (var e in roles) {
        debugPrint(" Device ID: ${e.deviceId}, Role: ${e.role}");
      }
    } catch (e) {
      errorSnackbar("Yetki Alınamadı", "Cihaz rolleri alınırken hata oluştu.");
    }
  }

  Future<bool> registerUser({
    required String fullName,
    required String mail,
    required String userName,
    required String telephone,
    required String password,
  }) async {
    try {
      final result = await AuthService.registerUser(
        fullName: fullName,
        mail: mail,
        userName: userName,
        telephone: telephone,
        password: password,
        identity: await getDeviceId(),
        platformName: platformName(),
      );

      if (result) {
        successSnackbar("Kayıt Başarılı", "Giriş yapıldı.");
        return true;
      } else {
        errorSnackbar("Hata", "Kayıt sırasında bir sorun oluştu.");
        return false;
      }
    } catch (e) {
      print("registerUser hatası: $e");
      errorSnackbar("Hata", "Bir hata oluştu: $e");
      return false;
    }
  }

  Future<int?> sendEmailVerificationCode(int userId, String email) async {
    try {
      if (email.trim().isEmpty || !email.contains('@')) {
        errorSnackbar(
            "Geçersiz E-posta", "Lütfen geçerli bir e-posta adresi giriniz.");
        return null;
      }

      final returnedUserId =
          await AuthService.sendEmailVerificationCode(userId, email.trim());

      successSnackbar(
        "Başarılı",
        "E-posta adresinize doğrulama kodu gönderildi.",
      );
      return returnedUserId;
    } catch (e) {
      final errorMessage = e.toString();

      if (errorMessage.contains("email_conflict")) {
        errorSnackbar(
            "Zaten Kayıtlı", "Bu e-posta ile zaten kayıtlı bir hesabınız var.");
      } else {
        errorSnackbar("Hata", "E-posta adresi kaydedilemedi");
      }

      return null;
    }
  }

  Future<UserDto?> verifyCode(int userId, String code) async {
    final user = await AuthService.verifyCode(userId, code);
    if (user != null) {
      successSnackbar("Başarılı", "Doğrulama kodu başarıyla onaylandı.");
      return user;
    } else {
      errorSnackbar("Hata", "Doğrulama kodu geçersiz.");
      return null;
    }
  }

  Future<bool> updateUserInfo({
    required String fullName,
    required String telephone,
    required String? mail,
    required int? active,
  }) async {
    final updatedUser = user.value.copyWith(
      fullName: fullName,
      telephone: telephone,
      mail: mail,
      active: active,
    );

    final result = await UserService.update(updatedUser);
    if (result != null) {
      user.value = result;
      user.refresh();
      update(['user']);
      return true;
    }
    return false;
  }

  Future<bool> completeProfile(String telephone, String fullName) async {
    try {
      final dto = UpdateGoogleUserDto(
        userId: user.value.id ?? 0,
        telephone: telephone,
        fullName: fullName,
      );

      final response = await AuthService.completeProfile(dto);
      return response;
    } catch (e) {
      print("AuthController > completeProfile hatası: $e");
      return false;
    }
  }

  Future<bool> completeRegisterUser({
    required String fullName,
    required String telephone,
    required String password,
  }) async {
    try {
      final dto = CompleteRegisterUserDto(
        userId: user.value.id ?? 0,
        fullName: fullName,
        telephone: telephone,
        password: password,
      );

      return await AuthService.completeRegisterUser(dto);
    } catch (e) {
      print("AuthController > completeRegisterUser error: $e");
      return false;
    }
  }

  Future<List<OperationClaim>?> getUserClaims() async {
    var claimsResult = await AuthService.getUserClaims();
    if (claimsResult != null) {
      return claimsResult;
    }
    return null;
  }

  Future<bool> terminateSession(int sessionId, String identity) async {
    try {
      await AuthService.logOut(sessionId, identity);
      return true;
    } catch (e) {
      print("Oturum sonlandırma hatası: $e");
      return false;
    }
  }

  Future<void> logOut(int sessionId, String identity,
      {BuildContext? context}) async {
    try {
      LoginController? loginController;
      try {
        loginController = Get.find<LoginController>();
      } catch (e) {
        print("LoginController bulunamadı: $e");
      }

      session.value = SessionDto.empty();
      user.value = UserDto();

      await LocalDb.delete(passwordKey);

      if (loginController != null) {
        await LocalDb.delete(webTokenKey);
        await LocalDb.delete(userIdKey);
        await LocalDb.delete(appleUserKey);
        loginController.isLogin.value = false;
      }

      try {
        await GoogleSignIn().signOut();
        print("Google oturumundan çıkıldı.");
      } catch (e) {
        print("Google çıkış hatası: $e");
      }

      try {
        await AuthService.logOut(sessionId, identity);
      } catch (e) {
        print("API çıkış hatası: $e");
      }

      await Future.delayed(Duration(milliseconds: 100));

      if (context != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => SplashPage(fromLogout: true)),
          (route) => false,
        );
      } else {
        Get.offAll(() => SplashPage(fromLogout: true));
      }
    } catch (e) {
      print("Logout işleminde hata: $e");
      if (context != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => SplashPage(fromLogout: true)),
          (route) => false,
        );
      } else {
        Get.offAll(() => SplashPage(fromLogout: true));
      }
    }
  }

  Future<void> logOut2(int sessionId, String identity) async {
    LoginController loginController = Get.find();
    await LocalDb.delete(webTokenKey);
    await LocalDb.delete(userIdKey);
    await LocalDb.delete(passwordKey);
    await LocalDb.remove(passwordKey);
    await LocalDb.delete(appleUserKey);
    await AuthService.logOut(sessionId, identity);
    await GoogleSignIn().signOut();

    session.value = SessionDto.empty();
    user.value = UserDto();

    await loginController.clearLoginInfo();
    Get.to(() => LoginPage());
  }

  Future<void> changePassword(
      String oldPassword, String newPassword, String identity) async {
    isLoading.value = true;
    isChanged.value = false;

    if (identity.isEmpty) {
      identity = await getDeviceId();
    }

    print("identity $identity");

    try {
      var result =
          await AuthService.changePassword(oldPassword, newPassword, identity);
      if (result) {
        isChanged.value = true;
        stopBackgroundService();
        String currentUserName = "";
        try {
          LoginController loginController = Get.find();
          currentUserName = loginController.userName.value;
        } catch (e) {
          print("LoginController bulunamadı: $e");
        }

        session.value = SessionDto.empty();
        user.value = UserDto();

        await LocalDb.clear();

        successSnackbar("Başarılı",
            "Şifreniz başarıyla değiştirildi. Giriş ekranına yönlendiriliyorsunuz");

        await Future.delayed(Duration(milliseconds: 500));

        Get.offAll(() =>
            SplashPage(fromLogout: true, autoFillUserName: currentUserName));
      } else {
        errorSnackbar("Hata", "Şifre güncellenemedi");
      }
    } catch (e) {
      errorSnackbar('Hata', 'Beklenmeyen bir hata oldu.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkSessions(context) async {
    if (oldSessions.isEmpty) {
      return;
    }
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          alignment: Alignment.centerLeft,
          content: SizedBox(
            width: width(context) * 0.90,
            height: height(context) * 0.40,
            child: Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Aktif Kullanılan Oturumlar",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemBuilder: (context, i) {
                        final session = oldSessions[i];
                        final canTerminate = session.id != null &&
                            session.platformIdentity != null;
                        return ListTile(
                          title: Text(session.platformName ?? "Bilinmiyor"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(getDate(session.lastActiveTime ?? "")),
                              Text(getTime(session.lastActiveTime ?? "")),
                            ],
                          ),
                          trailing: TextButton(
                            child: Text("Sonlandır"),
                            onPressed: canTerminate
                                ? () async {
                                    bool success = await terminateSession(
                                      session.id!,
                                      session.platformIdentity!,
                                    );

                                    if (success) {
                                      oldSessions.remove(session);

                                      if (oldSessions.isEmpty) {
                                        if (Navigator.canPop(context)) {
                                          Navigator.pop(context);
                                        }
                                      }
                                    } else {
                                      errorSnackbar(
                                          "Hata", "Oturum sonlandırılamadı.");
                                    }
                                  }
                                : null,
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      itemCount: oldSessions.length,
                    ),
                  ),
                ],
              );
            }),
          ),
          actions: [
            TextButton(
              child: Text("Vazgeç"),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
