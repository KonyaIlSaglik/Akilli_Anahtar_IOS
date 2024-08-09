import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/controllers/user_controller.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/models/login_model.dart';
import 'package:akilli_anahtar/models/token_model.dart';
import 'package:akilli_anahtar/pages/home/home_page.dart';
import 'package:akilli_anahtar/pages/login_page2.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/services/api/auth_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/custom_container.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool load = false;
  final AuthController _authController = Get.put(AuthController());
  final UserController _userController = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    if (mounted) {
      //initialization();
      init();
    }
  }

  init() async {
    await _authController.loadToken();
    if (_authController.isLoggedIn.value) {
      await _userController.getUser();
      Get.to(() => HomePage());
    } else {
      Get.to(() => LoginPage2());
    }
  }

  // void initialization() async {
  //   var tokenInfo = await LocalDb.get(tokenModelKey);
  //   if (tokenInfo != null) {
  //     var tokenModel = TokenModel.fromJson(tokenInfo);
  //     var eTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS+03:00")
  //         .parse(tokenModel.expiration);
  //     if (eTime.isBefore(DateTime.now())) {
  //       var info = await LocalDb.get(userKey);
  //       var user = User.fromJson(info!);
  //       var password = await LocalDb.get(passwordKey);
  //       if (password != null) {
  //         var result = await AuthService.login(
  //             LoginModel(userName: user.userName, password: password));
  //         if (result!.success!) {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute<void>(
  //               builder: (BuildContext context) => HomePage(),
  //             ),
  //           );
  //           return;
  //         }
  //       }
  //       CherryToast.error(
  //         toastPosition: Position.bottom,
  //         title: Text("Oturum açılamadı. Lütfen tekrar giriş yapınız."),
  //       ).show(context);
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute<void>(
  //           builder: (BuildContext context) => LoginPage2(),
  //         ),
  //       );
  //       return;
  //     }
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute<void>(
  //         builder: (BuildContext context) => HomePage(),
  //       ),
  //     );
  //     return;
  //   }
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute<void>(
  //       builder: (BuildContext context) => LoginPage2(),
  //     ),
  //   );
  // }

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
              Expanded(flex: 40, child: SizedBox(height: 0)),
              Expanded(flex: 1, child: Image.asset("assets/rdiot1.png")),
              Expanded(flex: 10, child: SizedBox(height: 0)),
            ],
          ),
        ),
      ),
    );
  }
}
