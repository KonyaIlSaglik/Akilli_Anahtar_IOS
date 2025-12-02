import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/widgets/app_input_field.dart';

class RegisterSendMailPage extends StatefulWidget {
  const RegisterSendMailPage({super.key});

  @override
  State<RegisterSendMailPage> createState() => _RegisterSendMailPageState();
}

class _RegisterSendMailPageState extends State<RegisterSendMailPage> {
  final TextEditingController emailController = TextEditingController();
  final AuthController authController = Get.find();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    final mailFromArguments = Get.arguments;
    if (mailFromArguments is String) {
      emailController.text = mailFromArguments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        //title: const Text("Kayıt Ol"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/open_email.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 25),
                Text(
                  "E-Mail Doğrulama",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Doğrulama kodunu göndermemiz için lütfen e-posta adresinizi girin",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                _buildEmailForm(),
                const SizedBox(height: 24),
                _buildSendButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: AppInputField(
        controller: emailController,
        icon: Icons.email_outlined,
        label: "E-posta Adresi",
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Lütfen e-posta adresinizi girin';
          }
          if (!value.contains('@')) {
            return 'Geçerli bir e-posta adresi girin';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: isLoading ? null : _sendVerification,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              )
            : const Text(
                "Doğrulama Kodu Gönder",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _sendVerification() async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final currentUserId = authController.user.value.id;

    if (currentUserId == null) {
      errorSnackbar("Hata", "Oturum bulunamadı. Lütfen tekrar giriş yapın.");
      return;
    }

    setState(() => isLoading = true);
    try {
      final returnedUserId =
          await authController.sendEmailVerificationCode(currentUserId, email);

      if (returnedUserId != null) {
        Get.toNamed("/VerifyCodePage", arguments: returnedUserId);
      } else {
        print("Kod gönderilemedi.");
      }
    } catch (e) {
      debugPrint("Kod gönderimi hatası: $e");
      errorSnackbar("Hata", "Beklenmeyen bir sorun oluştu.");
    } finally {
      setState(() => isLoading = false);
    }
  }
}
