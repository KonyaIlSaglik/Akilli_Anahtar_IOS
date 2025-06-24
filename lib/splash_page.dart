import 'package:akilli_anahtar/controllers/main/login_controller.dart';
import 'package:akilli_anahtar/pages/new_home/layout.dart';
import 'package:akilli_anahtar/pages/auth/login_page.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/custom_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  final bool fromLogout;
  const SplashPage({super.key, this.fromLogout = false});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool load = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    final LoginController loginController = Get.put(LoginController());
    await loginController.loadLoginInfo();

    if (widget.fromLogout) {
      await Future.delayed(Duration(milliseconds: 500));
      Get.offAll(() => LoginPage(),
          transition: Transition.fadeIn, duration: Duration(milliseconds: 300));
      return;
    }

    if (loginController.userName.value.isNotEmpty &&
        loginController.password.value.isNotEmpty) {
      await loginController.login();
      if (loginController.isLogin.value) {
        Get.offAll(() => Layout(),
            transition: Transition.fadeIn,
            duration: Duration(milliseconds: 300));
        return;
      }
    }

    await Future.delayed(Duration(milliseconds: 500));
    Get.offAll(() => LoginPage(),
        transition: Transition.fadeIn, duration: Duration(milliseconds: 300));
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
