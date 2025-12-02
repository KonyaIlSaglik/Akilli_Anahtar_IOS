import 'package:akilli_anahtar/controllers/main/login_controller.dart';
import 'package:akilli_anahtar/pages/profile/profile_edit_page.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/pages/auth/sifre_degistir.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authController = Get.find<AuthController>();
  final loginController = Get.find<LoginController>();

  Future<void> _refresh() async {
    try {
      authController.isLoading();
    } catch (_) {
      Get.snackbar("Hata", "Profil yenilenemedi",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: sheetBackground,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: sheetBackground,
      body: RefreshIndicator(
        color: goldColor,
        backgroundColor: Colors.white,
        onRefresh: _refresh,
        child: Obx(() {
          final user = authController.user.value;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTitle("Kullanıcı Bilgileri"),
              _infoTile(
                icon: Icons.person,
                title: "Ad Soyad",
                value: user.fullName,
                onEdit: () async {
                  final ok = await Get.to(() => ProfileEditPage());

                  if (ok == true) {
                    successSnackbar("Başarılı", "Güncelleme başarılı.");
                    _refresh();
                  }
                },
              ),
              _infoTile(
                icon: Icons.email,
                title: "E-posta",
                value: user.mail,
                trailing: user.isEmailVerified
                    ? _verifiedTag()
                    : _verifyAction("Doğrula", () {
                        Get.toNamed("/sendMail", arguments: user.mail);
                      }),
                onEdit: () async {
                  final ok = await Get.to(() => ProfileEditPage());
                  if (ok == true) _refresh();
                },
              ),
              _infoTile(
                icon: Icons.phone,
                title: "Telefon",
                value: user.telephone,
                onEdit: () async {
                  final ok = await Get.to(() => ProfileEditPage());
                  if (ok == true) _refresh();
                },
              ),
              const SizedBox(height: 24),
              _sectionTitle("Güvenlik"),
              _actionTile("Şifre Değiştir", Icons.lock_reset, () {
                Get.to(() => const SifreDegistirPage());
              }),
              const SizedBox(height: 24),
              _sectionTitle("Oturum"),
              _actionTile("Çıkış Yap", Icons.logout, () async {
                await authController.logOut2(
                  authController.session.value.id,
                  loginController.deviceId.value,
                );
              }),
            ],
          );
        }),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    String? value,
    VoidCallback? onEdit,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.brown.shade200),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.shade50,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.brown[400]),
        title: Text(title,
            style: const TextStyle(fontSize: 13, color: Colors.black54)),
        subtitle: Text(value ?? "-", style: const TextStyle(fontSize: 16)),
        trailing: trailing ??
            (onEdit != null
                ? IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                    onPressed: onEdit,
                  )
                : null),
      ),
    );
  }

  Widget _verifiedTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        "Doğrulandı",
        style: TextStyle(color: Colors.green, fontSize: 12),
      ),
    );
  }

  Widget _verifyAction(String label, VoidCallback? onTap,
      {bool disabled = false}) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: disabled ? Colors.grey.shade200 : Colors.red.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: disabled ? Colors.grey : Colors.red.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _actionTile(String label, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.brown.shade100),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.shade50,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.brown),
        title: Text(label),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}
