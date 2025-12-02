import 'package:akilli_anahtar/services/api/auth_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:akilli_anahtar/widgets/app_input_field.dart';
import 'package:get/get.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isSending = false;

  Future<void> _sendResetEmail() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isSending = true);

    final success =
        await AuthService.sendResetPasswordEmail(emailController.text.trim());

    if (success) {
      Get.back();
      successSnackbar("Başarılı",
          "Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.");
    } else {
      errorSnackbar("Hata", "Şifre sıfırlama bağlantısı gönderilemedi.");
    }

    setState(() => isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sheetBackground,
      appBar: AppBar(
        backgroundColor: sheetBackground,
        title: const Text("Şifremi Unuttum"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "E-posta adresinizi girin.",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                "Size bir şifre sıfırlama bağlantısı göndereceğiz.",
                style: TextStyle(color: Color.fromARGB(255, 69, 68, 68)),
              ),
              const SizedBox(height: 24),
              AppInputField(
                controller: emailController,
                icon: Icons.email_outlined,
                label: "E-posta",
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "E-posta adresi boş olamaz";
                  }
                  if (!GetUtils.isEmail(value)) {
                    return "Geçerli bir e-posta adresi girin";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSending ? null : _sendResetEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSending
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Gönder",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
