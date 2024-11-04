import 'package:akilli_anahtar/controllers/main/login_controller.dart';
import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/models/session_model.dart';
import 'package:akilli_anahtar/pages/auth/login_page.dart';
import 'package:akilli_anahtar/services/api/auth_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var isChanged = false.obs;
  var session = Session.empty().obs;
  var allSessions = <Session>[].obs;
  var user = User().obs;
  var operationClaims = <OperationClaim>[].obs;
  Future<List<OperationClaim>?> getUserClaims() async {
    var claimsResult = await AuthService.getUserClaims();
    if (claimsResult != null) {
      return claimsResult;
    }
    return null;
  }

  Future<void> logOut(int userId, String identity) async {
    LoginController loginController = Get.find();
    await AuthService.logOut(userId, identity);
    session.value = Session.empty();
    user.value = User();
    operationClaims.value = <OperationClaim>[];
    await loginController.clearLoginInfo();
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
        LoginController loginController = Get.find();
        loginController.password.value = newPassword;
        await loginController.saveLoginInfo();
      }
    } catch (e) {
      errorSnackbar('Error', 'Bir hata oldu. Tekrar deneyin.');
    } finally {
      isLoading.value = false;
    }
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
                      title: Text(allSessions[i].platformName ?? "Bilinmiyor"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(getDate(allSessions[i].loginTime)),
                          Text(getTime(allSessions[i].loginTime)),
                        ],
                      ),
                      trailing: TextButton(
                        child: Text("Sonlandır"),
                        onPressed: () async {
                          await logOut(
                            allSessions[i].userId,
                            allSessions[i].platformIdentity,
                          );
                          allSessions.remove(allSessions[i]);
                          if (allSessions.isEmpty) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  itemCount: allSessions.length,
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
