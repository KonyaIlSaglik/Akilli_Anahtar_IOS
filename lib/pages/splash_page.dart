import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/controllers/connectivity_controller.dart';
import 'package:akilli_anahtar/controllers/mqtt_controller.dart';
import 'package:akilli_anahtar/pages/home/home_page.dart';
import 'package:akilli_anahtar/pages/auth/login_page.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/custom_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool load = false;
  final AuthController _authController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    print("SplashPage started");
    Get.put(ConnectivityController());
    init();
  }

  init() async {
    await _authController.loadToken();
    // if (_authController.isLoggedIn.value) {
    //   Get.put(MqttController());
    //   Get.to(() => HomePage());
    // } else {
    //   Get.to(() => LoginPage());
    // }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        //
      },
      child: Scaffold(
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
      ),
    );
  }
}
