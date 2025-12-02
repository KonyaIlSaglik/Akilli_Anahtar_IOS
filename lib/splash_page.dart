import 'package:akilli_anahtar/controllers/main/login_controller.dart';
import 'package:akilli_anahtar/main.dart';
import 'package:akilli_anahtar/pages/new_home/layout.dart';
import 'package:akilli_anahtar/pages/auth/login_page.dart';
import 'package:akilli_anahtar/services/api/auth_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/custom_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  final bool fromLogout;
  final String autoFillUserName;
  const SplashPage(
      {super.key, this.fromLogout = false, this.autoFillUserName = ""});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool load = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 10), init);
  }

  void init() async {
    await checkNewVersion(context, false);

    bool canContinue = await checkNewVersion(context, false);
    if (!canContinue) {
      return;
    }

    if (_navigated) return;
    _navigated = true;

    final loginController = Get.put(LoginController());
    await loginController.loadLoginInfo();

    if (widget.fromLogout) {
      if (widget.autoFillUserName.isNotEmpty) {
        loginController.userName.value = widget.autoFillUserName;
      }
      Get.offAll(() => const LoginPage());
      return;
    }
    final googleSuccess = await AuthService.tryAutoGoogleLogin();
    final appleSucces = await AuthService.tryAutoAppleLogin();

    if (googleSuccess) {
      final route = fcmInitialRoute;
      fcmInitialRoute = null;
      Get.offAll(() => const Layout());
      if (route != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.toNamed(route);
        });
      }
      return;
    }

    if (appleSucces) {
      final route = fcmInitialRoute;
      fcmInitialRoute = null;
      Get.offAll(() => const Layout());
      if (route != null) {
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.toNamed(route);
        });
      }
      return;
    }

    if (loginController.userName.value.isNotEmpty &&
        loginController.password.value.isNotEmpty) {
      await loginController.login();

      if (loginController.isLogin.value) {
        final route = fcmInitialRoute;
        fcmInitialRoute = null;
        Get.offAll(() => const Layout());
        if (route != null) {
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.toNamed(route);
          });
        }
        return;
      }
    }

    Get.offAll(() => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomContainer(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(flex: 20, child: SizedBox(height: 0)),
            Expanded(flex: 20, child: Image.asset("assets/anahtar1.png")),
            Expanded(flex: 15, child: SizedBox(height: 0)),
            Expanded(
              flex: 15,
              child: SizedBox(
                height: 0,
                child: Center(
                  child: CircularProgressIndicator(
                    color: goldColor,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 10,
              child: Text(
                "Giriş yapılıyor...",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(flex: 10, child: SizedBox(height: 0)),
            Expanded(flex: 1, child: Image.asset("assets/rdiot1.png")),
            Expanded(flex: 10, child: SizedBox(height: 0)),
          ],
        ),
      ),
    );
  }
}
