import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/controllers/connectivity_controller.dart';
import 'package:akilli_anahtar/controllers/mqtt_controller.dart';
import 'package:akilli_anahtar/pages/home/home_page.dart';
import 'package:akilli_anahtar/pages/login_page2.dart';
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
    Get.put(ConnectivityController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  init() async {
    await _authController.loadToken();
    if (_authController.isLoggedIn.value) {
      Get.put(MqttController());
      Get.to(() => HomePage());
    } else {
      Get.to(() => LoginPage2());
    }
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
              Expanded(flex: 30, child: SizedBox(height: 0)),
              Expanded(flex: 20, child: Image.asset("assets/anahtar1.png")),
              Expanded(
                  flex: 40,
                  child: SizedBox(
                    height: 0,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: goldColor,
                      ),
                    ),
                  )),
              Expanded(flex: 1, child: Image.asset("assets/rdiot1.png")),
              Expanded(flex: 10, child: SizedBox(height: 0)),
            ],
          ),
        ),
      ),
    );
  }
}
