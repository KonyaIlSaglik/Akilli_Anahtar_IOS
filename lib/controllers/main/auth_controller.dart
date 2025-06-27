import 'package:akilli_anahtar/background_service.dart';
import 'package:akilli_anahtar/controllers/main/login_controller.dart';
import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/dtos/user_dto.dart';
import 'package:akilli_anahtar/dtos/session_dto.dart';
import 'package:akilli_anahtar/models/old_session_model.dart';
import 'package:akilli_anahtar/splash_page.dart';
import 'package:akilli_anahtar/services/api/auth_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  var session = SessionDto.empty().obs;
  var oldSessions = <OldSessionModel>[].obs;
  var user = UserDto().obs;
  var isLoading = false.obs;
  var isChanged = false.obs;
  var platformIdentity = "".obs;

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
    LoginController loginController = Get.find();
    session.value = SessionDto.empty();
    user.value = UserDto();
    /* await loginController.clearLoginInfo();

    if (context != null && Navigator.canPop(context)) {
      Navigator.pop(context);
      await Future.delayed(Duration(milliseconds: 100));
    }*/

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
  }

  Future<void> changePassword(
      String oldPassword, String newPassword, String identity) async {
    isLoading.value = true;
    isChanged.value = false;

    try {
      var result =
          await AuthService.changePassword(oldPassword, newPassword, identity);
      if (result) {
        isChanged.value = true;
        stopBackgroundService();

        LoginController loginController = Get.find();
        loginController.password.value = "";
        loginController.userName.value = "";

        final authController = Get.find<AuthController>();
        authController.session.value = SessionDto.empty();
        authController.user.value = UserDto();

        await LocalDb.clear();

        successSnackbar("Başarılı",
            "Şifreniz başarıyla değiştirildi. Giriş ekranına yönlendiriliyorsunuz");

        Get.reset();
        Get.offAllNamed("/login");
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
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          alignment: Alignment.centerLeft,
          content: SizedBox(
            width: width(context) * 0.90,
            height: height(context) * 0.40,
            child: Obx(
              () {
                return ListView.separated(
                  itemBuilder: (context, i) {
                    final session = oldSessions[i];
                    final canTerminate =
                        session.id != null && session.platformIdentity != null;
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
                );
              },
            ),
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
//push deneme