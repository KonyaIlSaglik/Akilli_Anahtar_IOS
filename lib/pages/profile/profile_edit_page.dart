import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/controllers/main/login_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/app_input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final authController = Get.find<AuthController>();
  final loginController = Get.find<LoginController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController fullNameController;
  late TextEditingController telephoneController;
  late TextEditingController mailController;

  @override
  void initState() {
    super.initState();
    final user = authController.user.value;
    fullNameController = TextEditingController(text: user.fullName);
    telephoneController = TextEditingController(text: user.telephone);
    mailController = TextEditingController(text: user.mail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Bilgileri Güncelle"),
          backgroundColor: sheetBackground),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppInputField(
                controller: fullNameController,
                icon: Icons.person,
                label: "Ad Soyad",
                validator: (value) =>
                    value == null || value.isEmpty ? "Zorunlu alan" : null,
              ),
              const SizedBox(height: 16),
              AppInputField(
                controller: telephoneController,
                icon: Icons.phone,
                label: "Telefon",
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? "Zorunlu alan" : null,
              ),
              const SizedBox(height: 16),
              AppInputField(
                controller: mailController,
                icon: Icons.email,
                label: "E-posta",
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || value.isEmpty
                    ? "Zorunlu alan"
                    : !GetUtils.isEmail(value)
                        ? "Geçerli bir e-posta girin"
                        : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitUpdate,
                child: const Text("Kaydet"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: goldColor,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 70),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                onPressed: _confirmFreezeAccount,
                child: const Text("Hesabımı Sil"),
              )
            ],
          ),
        ),
      ),
    );
  }

  // GÜNCEL SAYFA
  void _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      final ok = await authController.updateUserInfo(
        fullName: fullNameController.text,
        telephone: telephoneController.text,
        mail: mailController.text,
        active: 1,
      );
      if (ok) {
        Get.back(result: true);
      } else {
        errorSnackbar("Hata", "Güncelleme başarısız");
      }
    }
  }

  void _confirmFreezeAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hesabını Dondur"),
        content: const Text("Hesabını dondurmak istediğine emin misin?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("İptal")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Evet")),
        ],
      ),
    );

    if (confirmed == true) {
      final updatedUser = authController.user.value.copyWith(active: 0);
      final result = await authController.updateUserInfo(
        fullName: updatedUser.fullName ?? "",
        telephone: updatedUser.telephone ?? "",
        mail: updatedUser.mail,
        active: 0,
      );

      if (result) {
        Get.snackbar("Başarılı", "Hesap donduruldu");
        await authController.logOut2(
          authController.session.value.id,
          loginController.deviceId.value,
        );
      } else {
        Get.snackbar("Hata", "Hesap dondurulamadı");
      }
    }
  }
}
