import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/custom_text_field.dart';
import 'package:get/get.dart';

class SifreDegistirPage extends StatefulWidget {
  const SifreDegistirPage({Key? key}) : super(key: key);

  @override
  State<SifreDegistirPage> createState() => _SifreDegistirPageState();
}

class _SifreDegistirPageState extends State<SifreDegistirPage> {
  bool keboardVisible = false;
  String password = "";
  final oldPasswordCont = TextEditingController(text: "");
  final oldPasswordFocus = FocusNode();
  final newPasswordCont = TextEditingController(text: "");
  final newPasswordFocus = FocusNode();
  final newPasswordAgainCont = TextEditingController(text: "");
  final newPasswordAgainFocus = FocusNode();
  final AuthController _authController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardVisibilityController.onChange.listen((bool visible) {
      setState(() {
        keboardVisible = visible;
      });
    });
    oldPasswordCont.text = _authController.loginModel.value.password;
  }

  @override
  void dispose() {
    super.dispose();
    //FocusScope.of(context).dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: PopScope(
        onPopInvoked: (didPop) async {
          Navigator.pop(context);
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: height * 0.030,
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: height * 0.04),
                  child: SizedBox(
                    height: keboardVisible ? height * 0.10 : height * 0.20,
                    child: Image.asset(
                      "assets/anahtar.png",
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.70,
                  child: Card(
                    elevation: 0,
                    color: goldColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: height * 0.03),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(
                              keboardVisible ? height * 0.01 : height * 0.025,
                            ),
                            child: Text(
                              "Şifre Değiştir",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headlineLarge!
                                    .fontSize,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          CustomTextField(
                            controller: oldPasswordCont,
                            focusNode: oldPasswordFocus,
                            nextFocus: newPasswordFocus,
                            icon: Icon(Icons.lock),
                            hintText: "Eski Şifre",
                            isPassword: true,
                          ),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: height * 0.020),
                            child: CustomTextField(
                              controller: newPasswordCont,
                              focusNode: newPasswordFocus,
                              nextFocus: newPasswordAgainFocus,
                              icon: Icon(Icons.lock),
                              hintText: "Yeni Şifre",
                              isPassword: true,
                            ),
                          ),
                          CustomTextField(
                            controller: newPasswordAgainCont,
                            focusNode: newPasswordAgainFocus,
                            icon: Icon(Icons.lock),
                            hintText: "Yeni Şifre Tekrar",
                            isPassword: true,
                          ),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: height * 0.025),
                            child: Obx(() {
                              return CustomButton(
                                title: "KAYDET",
                                loading: _authController.isLoading.value,
                                onPressed: () {
                                  sifreDegistir(context);
                                },
                              );
                            }),
                          ),
                          otherButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  sifreDegistir(context) async {
    if (oldPasswordCont.text != _authController.loginModel.value.password) {
      errorSnackbar("Hata", "Eski şifre hatalı.");
      return;
    }
    if (oldPasswordCont.text.isEmpty) {
      errorSnackbar("Hata", "Eski şifre boş olamaz.");
      return;
    }
    if (newPasswordCont.text.isEmpty) {
      errorSnackbar("Hata", "Yeni şifre boş olamaz.");
      return;
    }
    if (newPasswordCont.text != newPasswordAgainCont.text) {
      errorSnackbar("Hata", "Şifreler eşleşmiyor.");
      return;
    }

    await _authController.changePassword(
        oldPasswordCont.text, newPasswordCont.text);

    if (_authController.isChanged.value) {
      oldPasswordCont.text = _authController.loginModel.value.password;
      infoSnackbar("Bilgilendirme", "Şifre Değiştirildi");
    }

    newPasswordCont.text = "";
    newPasswordAgainCont.text = "";
  }

  otherButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          child: Text(
            'Vazgeç',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
