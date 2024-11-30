import 'package:akilli_anahtar/controllers/main/login_controller.dart';
import 'package:akilli_anahtar/pages/auth/login_page_form_input_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';

class SifreDegistirPage extends StatefulWidget {
  const SifreDegistirPage({super.key});

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
  LoginController loginController = Get.find();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardVisibilityController.onChange.listen((bool visible) {
      setState(() {
        keboardVisible = visible;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: goldColor,
        foregroundColor: goldColor,
        elevation: 10,
        title: Text(
          "ŞİFRE DEĞİŞTİR",
          style: (width(context) < minWidth
                  ? textTheme(context).titleMedium!
                  : textTheme(context).titleLarge!)
              .copyWith(color: goldColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: height * 0.030,
          ),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(height: height * 0.05),
                SizedBox(
                  height: height * 0.07,
                  width: width(context) * 0.90,
                  child: LoginPageFormInputText(
                    controller: oldPasswordCont,
                    isPassword: true,
                    hintText: "Eski Şifre",
                    focusNode: oldPasswordFocus,
                    nextFocusNode: newPasswordFocus,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Boş geçilemez";
                      }
                      if (value != loginController.password.value) {
                        return "Eski Şifre Hatalı";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: height * 0.02),
                SizedBox(
                  height: height * 0.07,
                  width: width(context) * 0.90,
                  child: LoginPageFormInputText(
                    controller: newPasswordCont,
                    nextFocusNode: newPasswordAgainFocus,
                    isPassword: true,
                    hintText: "Yeni Şifre",
                    focusNode: newPasswordFocus,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Boş geçilemez";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: height * 0.02),
                SizedBox(
                  height: height * 0.07,
                  width: width(context) * 0.90,
                  child: LoginPageFormInputText(
                    controller: newPasswordAgainCont,
                    isPassword: true,
                    hintText: "Yeni Şifre Tekrar",
                    focusNode: newPasswordAgainFocus,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Boş geçilemez";
                      }
                      if (value != newPasswordCont.text) {
                        return "Şifreler eşleşmiyor";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                SizedBox(
                  height: height * 0.06,
                  width: width(context) * 0.50,
                  child: InkWell(
                    onTap: () {
                      if (formKey.currentState!.validate()) {}
                    },
                    child: Card(
                      elevation: 5,
                      color: goldColor.withOpacity(0.7),
                      child: Center(
                        child: Text(
                          "KAYDET",
                          style: textTheme(context)
                              .headlineLarge!
                              .copyWith(color: Colors.white),
                        ),
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
}
