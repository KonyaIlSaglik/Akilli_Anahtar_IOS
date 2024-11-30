import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/controllers/main/login_controller.dart';
import 'package:akilli_anahtar/layout.dart';
import 'package:akilli_anahtar/pages/auth/login_page_form_input_text.dart';
import 'package:akilli_anahtar/pages/auth/login_page_form_privacy_policy.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPageForm extends StatefulWidget {
  const LoginPageForm({super.key});

  @override
  State<LoginPageForm> createState() => _LoginPageFormState();
}

const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

class _LoginPageFormState extends State<LoginPageForm> {
  LoginController loginController = Get.find();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    print("LoginPageForm initialized");
    userNameController.text = loginController.userName.value;
    passwordController.text = loginController.password.value;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Form(
          key: formKey,
          child: Column(
            children: [
              SizedBox(
                height: height(context) * 0.07,
                width: width(context) * 0.90,
                child: LoginPageFormInputText(
                  controller: userNameController,
                  focusNode: loginController.userNameFocus,
                  nextFocusNode: loginController.passwordFocus,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Boş geçilemez";
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(
                height: height(context) * 0.01,
              ),
              SizedBox(
                height: height(context) * 0.07,
                width: width(context) * 0.90,
                child: LoginPageFormInputText(
                  controller: passwordController,
                  isPassword: true,
                  focusNode: loginController.passwordFocus,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Boş geçilemez";
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(
                height: height(context) * 0.01,
              ),
              SizedBox(
                height: height(context) * 0.05,
                child: LoginPageFormPrivacyPolicy(),
              ),
              SizedBox(
                height: height(context) * 0.02,
              ),
              SizedBox(
                height: height(context) * 0.07,
                width: width(context) * 0.50,
                child: InkWell(
                  onTap: loginController.privacyPolicy.value
                      ? () async {
                          if (formKey.currentState!.validate()) {
                            loginController.userName.value =
                                userNameController.text;
                            loginController.password.value =
                                passwordController.text;
                            await loginController.login();
                            if (loginController.isLogin.value) {
                              Get.to(() => Layout());
                            } else {
                              AuthController authController = Get.find();
                              if (authController.allSessions.isNotEmpty) {
                                authController.checkSessions(context);
                              }
                              passwordController.text = "";
                            }
                          }
                        }
                      : null,
                  child: Card(
                    elevation: loginController.privacyPolicy.value ? 10 : 10,
                    color: loginController.privacyPolicy.value
                        ? goldColor.withOpacity(0.7)
                        : goldColor.withOpacity(0.3),
                    child: Center(
                      child: Text(
                        "GİRİŞ",
                        style: textTheme(context)
                            .headlineLarge!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              // SizedBox(height: height(context) * 0.02),
              // IconButton(
              //   onPressed: () {
              //     GoogleSignIn googleSignIn = GoogleSignIn(
              //       scopes: scopes,
              //     );
              //   },
              //   icon: Card(
              //     elevation: 5,
              //     shape: CircleBorder(),
              //     child: CircleAvatar(
              //       backgroundColor: goldColor.withOpacity(0.3),
              //       child: Icon(
              //         FontAwesomeIcons.google,
              //         color: Colors.blue,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }
}
