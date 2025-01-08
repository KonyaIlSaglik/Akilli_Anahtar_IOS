import 'package:akilli_anahtar/controllers/main/login_controller.dart';
import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/dtos/user_dto.dart';
import 'package:akilli_anahtar/dtos/session_dto.dart';
import 'package:akilli_anahtar/models/old_session_model.dart';
import 'package:akilli_anahtar/pages/auth/login_page.dart';
import 'package:akilli_anahtar/services/api/auth_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  var session = SessionDto.empty().obs;
  var oldSessions = <OldSessionModel>[].obs;
  var user = UserDto().obs;

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
    session.value = SessionDto.empty();
    user.value = UserDto();
    await loginController.clearLoginInfo();
    Get.to(() => LoginPage());
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    // isChanged.value = false;
    // isLoading.value = true;
    // try {
    //   var response = await AuthService.changePassword(oldPassword, newPassword);
    //   if (response != null) {
    //     session.value = response;
    //     isChanged.value = true;
    //     LoginController loginController = Get.find();
    //     loginController.password.value = newPassword;
    //     await loginController.saveLoginInfo();
    //   }
    // } catch (e) {
    //   errorSnackbar('Error', 'Bir hata oldu. Tekrar deneyin.');
    // } finally {
    //   isLoading.value = false;
    // }
  }

  void checkSessions(context) {
    showDialog(
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
