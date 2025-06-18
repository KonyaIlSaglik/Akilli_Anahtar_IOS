import 'package:akilli_anahtar/background_service.dart';
import 'package:akilli_anahtar/controllers/main/login_controller.dart';
import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/dtos/user_dto.dart';
import 'package:akilli_anahtar/dtos/session_dto.dart';
import 'package:akilli_anahtar/models/old_session_model.dart';
import 'package:akilli_anahtar/pages/auth/login_page.dart';
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

  Future<void> logOut(int sessionId, String identity) async {
    LoginController loginController = Get.find();
    await AuthService.logOut(sessionId, identity);
    Get.offAll(() => const LoginPage());
    await Future.delayed(Duration(milliseconds: 100));
    session.value = SessionDto.empty();
    user.value = UserDto();
    await loginController.clearLoginInfo();
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
                    return ListTile(
                      title: Text(oldSessions[i].platformName ?? "Bilinmiyor"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(getDate(oldSessions[i].lastActiveTime!)),
                          Text(getTime(oldSessions[i].lastActiveTime!)),
                        ],
                      ),
                      trailing: TextButton(
                        child: Text("Sonlandır"),
                        onPressed: () async {
                          await logOut(
                            oldSessions[i].id!,
                            oldSessions[i].platformIdentity!,
                          );
                          oldSessions.remove(oldSessions[i]);
                          if (oldSessions.isEmpty) {
                            Navigator.pop(context);
                          }
                        },
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
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
