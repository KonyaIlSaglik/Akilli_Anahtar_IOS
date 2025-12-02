import 'dart:async';
import 'package:akilli_anahtar/controllers/main/login_controller.dart';
import 'package:akilli_anahtar/pages/auth/login_page_form_input_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';

class SifreDegistirPage extends StatefulWidget {
  const SifreDegistirPage({super.key});

  @override
  State<SifreDegistirPage> createState() => _SifreDegistirPageState();
}

class _SifreDegistirPageState extends State<SifreDegistirPage> {
  bool keboardVisible = false;

  final oldPasswordCont = TextEditingController(text: "");
  final oldPasswordFocus = FocusNode();

  final newPasswordCont = TextEditingController(text: "");
  final newPasswordFocus = FocusNode();

  final newPasswordAgainCont = TextEditingController(text: "");
  final newPasswordAgainFocus = FocusNode();

  final formKey = GlobalKey<FormState>();
  final loginController = Get.find<LoginController>();
  final auth = Get.find<AuthController>();

  StreamSubscription<bool>? _keyboardSub;

  @override
  void initState() {
    super.initState();
    _keyboardSub = KeyboardVisibilityController().onChange.listen((visible) {
      if (!mounted) return;
      setState(() => keboardVisible = visible);
    });
  }

  @override
  void dispose() {
    _keyboardSub?.cancel();

    oldPasswordCont.dispose();
    newPasswordCont.dispose();
    newPasswordAgainCont.dispose();
    oldPasswordFocus.dispose();
    newPasswordFocus.dispose();
    newPasswordAgainFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: sheetBackground,
      appBar: AppBar(
        title: const Text("Şifre Değiştir"),
        backgroundColor: sheetBackground,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _inputCard(
                child: LoginPageFormInputText(
                  controller: oldPasswordCont,
                  isPassword: true,
                  hintText: "Eski Şifre",
                  focusNode: oldPasswordFocus,
                  nextFocusNode: newPasswordFocus,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Boş geçilemez";
                    return null;
                  },
                ),
              ),
              _inputCard(
                child: LoginPageFormInputText(
                  controller: newPasswordCont,
                  nextFocusNode: newPasswordAgainFocus,
                  isPassword: true,
                  hintText: "Yeni Şifre",
                  focusNode: newPasswordFocus,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Boş geçilemez";
                    if (value.length < 6) return "En az 6 karakter olmalı";
                    return null;
                  },
                ),
              ),
              _inputCard(
                child: LoginPageFormInputText(
                  controller: newPasswordAgainCont,
                  isPassword: true,
                  hintText: "Yeni Şifre Tekrar",
                  focusNode: newPasswordAgainFocus,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Boş geçilemez";
                    if (value != newPasswordCont.text) {
                      return "Şifreler eşleşmiyor";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 12),
              _saveButton(
                label: "Kaydet",
                onTap: () async {
                  if (!formKey.currentState!.validate()) return;
                  await auth.changePassword(oldPasswordCont.text,
                      newPasswordCont.text, loginController.deviceId.value);
                },
              ),
              SizedBox(height: keboardVisible ? 12 : h * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputCard({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: child,
    );
  }

  Widget _saveButton({required String label, required VoidCallback onTap}) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: Colors.brown[400],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 16,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
