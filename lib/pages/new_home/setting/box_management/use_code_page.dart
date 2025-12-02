import 'package:akilli_anahtar/pages/new_home/layout.dart';
import 'package:akilli_anahtar/services/api/management_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/app_input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UseCodePage extends StatefulWidget {
  const UseCodePage({super.key});

  @override
  State<UseCodePage> createState() => _UseCodePageState();
}

class _UseCodePageState extends State<UseCodePage> {
  final TextEditingController codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yönetici Kodu Giriş"),
        backgroundColor: sheetBackground,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: lightBlue,
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text("Yöneticiden Aldığınız Kodunu Girin"),
                  subtitle: const Text(
                    "Yöneticiden aldığınız 5 haneli kodu buraya giriniz.",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppInputField(
                controller: codeController,
                icon: Icons.code,
                label: "Paylaşım Kodu",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: goldColor,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: loading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;

                          setState(() => loading = true);

                          final result = await ManagementService.useShareCode(
                              codeController.text.trim());

                          setState(() => loading = false);

                          if (result != null) {
                            successSnackbar(
                                "Başarılı", "Cihaza başarıyla katıldınız.");
                            Get.offAllNamed('/layout');
                          } else {
                            errorSnackbar("Hata",
                                "Kod geçerli değil veya süresi dolmuş.");
                          }
                        },
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Kodu Kullan",
                          style: TextStyle(fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
