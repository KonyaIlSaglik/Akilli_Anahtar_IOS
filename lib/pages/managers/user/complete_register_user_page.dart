import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class CompleteRegisterUserPage extends StatefulWidget {
  const CompleteRegisterUserPage({super.key});

  @override
  State<CompleteRegisterUserPage> createState() =>
      _CompleteRegisterUserPageState();
}

class _CompleteRegisterUserPageState extends State<CompleteRegisterUserPage> {
  final authController = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final telephoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = authController.user.value;
    fullNameController.text = user.fullName ?? "";
    telephoneController.text = user.telephone ?? "";
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      errorSnackbar("Hata", "Şifreler eşleşmiyor.");
      return;
    }

    setState(() => isLoading = true);

    final success = await authController.completeRegisterUser(
      fullName: fullNameController.text.trim(),
      telephone: telephoneController.text.trim(),
      password: passwordController.text,
    );

    setState(() => isLoading = false);

    if (success) {
      successSnackbar("Başarılı", "Profil tamamlandı.");
      Get.offAllNamed("/home");
    } else {
      errorSnackbar("Hata", "Profil tamamlanamadı.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        title: const Text("Profilini Tamamla"),
        centerTitle: true,
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: fullNameController,
                  decoration: const InputDecoration(
                    labelText: "Ad Soyad",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? "Ad Soyad gerekli"
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: telephoneController,
                  decoration: const InputDecoration(
                    labelText: "Telefon",
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (val) => val == null || val.trim().isEmpty
                      ? "Telefon gerekli"
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Şifre",
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (val) =>
                      val == null || val.length < 6 ? "En az 6 karakter" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Şifre Tekrar",
                    prefixIcon: Icon(Icons.lock_reset_outlined),
                  ),
                  validator: (val) =>
                      val == null || val != passwordController.text
                          ? "Şifreler aynı olmalı"
                          : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Kaydet", style: TextStyle(fontSize: 16)),
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
