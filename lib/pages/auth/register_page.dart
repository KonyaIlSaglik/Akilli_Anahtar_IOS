import 'package:akilli_anahtar/services/api/auth_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/app_input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final mailController = TextEditingController();
  final userNameController = TextEditingController();
  final telephoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final focusMail = FocusNode();
  final focusUserName = FocusNode();
  final focusTelephone = FocusNode();
  final focusPassword = FocusNode();
  final focusConfirmPassword = FocusNode();

  bool isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      errorSnackbar("Hata", "Şifreler uyuşmuyor");
      return;
    }

    setState(() => isLoading = true);

    final success = await AuthService.registerUser(
      fullName: fullNameController.text.trim(),
      mail: mailController.text.trim(),
      userName: userNameController.text.trim(),
      telephone: telephoneController.text.trim(),
      password: passwordController.text,
      identity: await getDeviceId(),
      platformName: "flutter",
    );

    setState(() => isLoading = false);

    if (success) {
      successSnackbar("Kayıt Başarılı", "Lütfen giriş yapın.");
      Get.offAllNamed("/verifyEmail");
    } else {
      errorSnackbar("Hata", "Kayıt işlemi başarısız.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text("Kayıt Ol"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppInputField(
                  controller: fullNameController,
                  icon: Icons.person,
                  label: "Ad Soyad",
                  nextFocus: focusMail,
                ),
                AppInputField(
                  controller: telephoneController,
                  icon: Icons.phone,
                  label: "Telefon",
                  keyboardType: TextInputType.phone,
                  focusNode: focusTelephone,
                  nextFocus: focusPassword,
                ),
                AppInputField(
                  controller: mailController,
                  icon: Icons.email,
                  label: "E-mail",
                  keyboardType: TextInputType.emailAddress,
                  focusNode: focusMail,
                  nextFocus: focusUserName,
                ),
                AppInputField(
                  controller: passwordController,
                  icon: Icons.lock_outline,
                  label: "Şifre",
                  obscure: true,
                  focusNode: focusPassword,
                  nextFocus: focusConfirmPassword,
                ),
                AppInputField(
                  controller: confirmPasswordController,
                  icon: Icons.lock,
                  label: "Şifre Tekrar",
                  obscure: true,
                  focusNode: focusConfirmPassword,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Kayıt Ol",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
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
