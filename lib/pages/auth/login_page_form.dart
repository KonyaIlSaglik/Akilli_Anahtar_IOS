import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/controllers/main/login_controller.dart';
import 'package:akilli_anahtar/pages/auth/forgot_password_page.dart';
import 'package:akilli_anahtar/pages/new_home/layout.dart';
import 'package:akilli_anahtar/widgets/app_input_field.dart';
import 'package:akilli_anahtar/pages/auth/login_page_form_privacy_policy.dart';
import 'package:akilli_anahtar/services/api/auth_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:akilli_anahtar/pages/auth/register_page.dart';

class LoginPageForm extends StatefulWidget {
  const LoginPageForm({super.key});

  @override
  State<LoginPageForm> createState() => _LoginPageFormState();
}

class _LoginPageFormState extends State<LoginPageForm> {
  final LoginController loginController = Get.find();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    userNameController.text = loginController.userName.value;
    passwordController.text = loginController.password.value;

    ever(loginController.userName, (value) {
      if (userNameController.text != value) {
        userNameController.text = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isShort = constraints.maxHeight < 650;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment:
                  isShort ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                if (isShort) const SizedBox(height: 60),
                AppInputField(
                  controller: userNameController,
                  focusNode: loginController.userNameFocus,
                  nextFocus: loginController.passwordFocus,
                  icon: Icons.person_outline,
                  label: "Kullanıcı Adı",
                ),
                const SizedBox(height: 12),
                AppInputField(
                  controller: passwordController,
                  focusNode: loginController.passwordFocus,
                  icon: Icons.lock_outline,
                  label: "Şifre",
                  obscure: true,
                ),
                const SizedBox(height: 2),
                _buildForgotPassword(),
                const SizedBox(height: 1),
                const LoginPageFormPrivacyPolicy(),
                const SizedBox(height: 16),
                _buildLoginButton(),
                const SizedBox(height: 16),
                _buildDividerWithText("veya"),
                const SizedBox(height: 16),
                _buildAppleButton(),
                const SizedBox(height: 10),
                _buildGoogleButton(),
                const SizedBox(height: 10),
                _buildRegisterButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Get.to(() => const ForgotPasswordPage()),
        child: Text(
          "Şifremi Unuttum?",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    final isPolicyAccepted = loginController.privacyPolicy.value;
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: isPolicyAccepted ? _handleLogin : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: loginController.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                "GİRİŞ YAP",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    try {
      if (!formKey.currentState!.validate()) return;

      loginController.userName.value = userNameController.text;
      loginController.password.value = passwordController.text;
      loginController.isLoading.value = true;

      final success = await loginController.login();

      if (success) {
        Get.offAll(() => const Layout());
        return;
      }

      final authController = Get.find<AuthController>();
      await authController.checkSessions(context);

      if (authController.oldSessions.isEmpty) {
        final retrySuccess = await loginController.login();
        if (retrySuccess) {
          Get.offAll(() => const Layout());
        } else {
          passwordController.clear();
        }
      } else {
        passwordController.clear();
      }
    } catch (e) {
      if (e.toString().contains("email_conflict")) {
        errorSnackbar("Hata", "Bu e-posta adresi başka bir kullanıcıya ait.");
      } else {
        errorSnackbar("Hata", "Giriş yapılamadı. Lütfen tekrar deneyin.");
      }
    } finally {
      loginController.isLoading.value = false;
    }
  }

  Widget _buildDividerWithText(String text) {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1, color: Colors.grey)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider(thickness: 1, color: Colors.grey)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    final isPolicyAccepted = loginController.privacyPolicy.value;
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: OutlinedButton(
        onPressed: isPolicyAccepted ? _handleGoogleLogin : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/google_icon2.png", height: 18),
            const SizedBox(width: 12),
            Text(
              "Google ile Giriş Yap",
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    final success = await AuthService.loginWithGoogle();
    if (!success) {
      print("Google ile giriş başarısız.");
    }
  }

  Widget _buildAppleButton() {
    final isPolicyAccepted = loginController.privacyPolicy.value;

    return SizedBox(
      width: double.infinity,
      height: 40,
      child: OutlinedButton(
        onPressed: isPolicyAccepted ? _handleAppleLogin : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: Colors.black),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.apple, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Text(
              "Apple ile Giriş Yap",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAppleLogin() async {
    final success = await AuthService.loginWithApple();
    if (!success) {
      print("Apple ile giriş başarısız.");
    }
  }

  Widget _buildRegisterButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Hesabınız yok mu?", style: TextStyle(color: Colors.grey[600])),
        TextButton(
          onPressed: () => Get.to(() => const RegisterPage()),
          child: Text(
            "Kayıt Ol",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
