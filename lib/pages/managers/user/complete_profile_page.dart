import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage>
    with TickerProviderStateMixin {
  final authController = Get.find<AuthController>();
  final fullNameController = TextEditingController();
  final telephoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final user = authController.user.value;
    fullNameController.text = user.fullName ?? "";
    telephoneController.text = user.telephone ?? "";
  }

  void _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      final result = await authController.completeProfile(
        telephoneController.text,
        fullNameController.text,
      );

      if (result) {
        Get.offAllNamed('/layout');
      } else {
        Get.snackbar("Hata", "Bilgiler güncellenemedi");
      }
    } else {
      print("Form doğrulanamadı, alanları doldurun.");
    }
  }

  Widget textFormField({
    required BuildContext context,
    required TextEditingController controller,
    required String labelText,
    required int index,
    bool obscureText = false,
    bool readOnly = false,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      height: height(context) * 0.07,
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme:
              TextSelectionThemeData(selectionHandleColor: goldColor),
        ),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          cursorColor: goldColor,
          readOnly: readOnly,
          enabled: enabled,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle:
                textTheme(context).labelMedium!.copyWith(color: goldColor),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(style: BorderStyle.solid, color: goldColor),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(style: BorderStyle.solid, color: goldColor),
            ),
          ),
          style: textTheme(context).titleSmall,
          validator: (value) {
            if (readOnly) return null;
            if (value == null || value.isEmpty) {
              if (index == 0) return "Ad soyad boş olamaz";
              if (index == 1) return "Telefon boş olamaz";
            }
            return null;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authController.user.value;
    final mailController = TextEditingController(text: user.mail ?? "");
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        await GoogleSignIn().signOut();
        Get.offAllNamed('/login');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Kullanıcıyı Düzenle"),
          backgroundColor: sheetBackground,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                textFormField(
                  context: context,
                  controller: fullNameController,
                  labelText: "Ad Soyad",
                  index: 0,
                ),
                SizedBox(height: 12),
                textFormField(
                  context: context,
                  controller: telephoneController,
                  labelText: "Telefon Numarası",
                  keyboardType: TextInputType.phone,
                  index: 1,
                ),
                SizedBox(height: 12),
                textFormField(
                  context: context,
                  controller: mailController,
                  labelText: "E-posta",
                  readOnly: true,
                  enabled: false,
                  index: 3,
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: width(context) * 0.5,
                  height: height(context) * 0.06,
                  child: InkWell(
                    onTap: _submitUpdate,
                    child: Card(
                      elevation: 5,
                      color: goldColor.withOpacity(0.7),
                      child: Center(
                        child: Text(
                          "Kaydet",
                          style: textTheme(context)
                              .titleLarge!
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
