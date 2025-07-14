import 'package:akilli_anahtar/pages/auth/login_page_form.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/version_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool keboardVisible = false;

  @override
  void initState() {
    super.initState();
    print("LoginPage started");
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardVisibilityController.onChange.listen((bool visible) {
      if (mounted) {
        setState(() {
          keboardVisible = visible;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width(context) * 0.05,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: keboardVisible
                    ? height(context) * 0.10
                    : height(context) * 0.20,
              ),
              SizedBox(
                height: height(context) * 0.10,
                child: Image.asset(
                  "assets/anahtar.png",
                ),
              ),
              SizedBox(
                height: height(context) * 0.10,
              ),
              LoginPageForm(),
              SizedBox(
                height: keboardVisible
                    ? height(context) * 0.05
                    : height(context) * 0.25,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    VersionText(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
