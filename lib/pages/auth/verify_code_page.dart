import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/pages/auth/send_email_verify_code.dart';
import 'package:akilli_anahtar/pages/new_home/layout.dart';
import 'package:akilli_anahtar/services/api/auth_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class VerifyCodePage extends StatefulWidget {
  const VerifyCodePage({super.key});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage>
    with WidgetsBindingObserver {
  final authController = Get.find<AuthController>();
  late int userId;

  final _otpCtrl = TextEditingController();
  final _otpFocus = FocusNode();

  bool isLoading = false;
  bool _autoSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final arg = Get.arguments;
    if (arg is int) {
      userId = arg;
    } else if (arg is String && int.tryParse(arg) != null) {
      userId = int.parse(arg);
    } else {
      Get.snackbar("Hata", "Geçersiz kullanıcı ID'si");
      Get.offAllNamed("/login");
      return;
    }

    _otpCtrl.addListener(() {
      if (_otpCtrl.text.length == 5 && !_autoSubmitting) {
        _autoSubmitting = true;
        Future.microtask(_submitCode);
      }
      setState(() {});
    });

    _otpFocus.addListener(() => setState(() {}));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refocusOtp(forceShowKeyboard: true));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _otpCtrl.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  void _refocusOtp({bool forceShowKeyboard = false}) {
    if (!mounted) return;
    FocusScope.of(context).requestFocus(_otpFocus);
    _otpCtrl.selection = TextSelection.collapsed(offset: _otpCtrl.text.length);

    if (forceShowKeyboard) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!mounted) return;
        SystemChannels.textInput.invokeMethod('TextInput.show');
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refocusOtp(forceShowKeyboard: true);
      });
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _refocusOtp(forceShowKeyboard: true));
    }
  }

  Future<void> _submitCode() async {
    final code = _otpCtrl.text;
    if (code.length != 5) return;

    FocusScope.of(context).unfocus();
    setState(() => isLoading = true);

    try {
      final user = await authController.verifyCode(userId, code);
      if (!mounted) return;
      if (user != null) {
        authController.user.value = user;
        Get.offAllNamed('/layout');
      } else {
        _otpCtrl.clear();
        _autoSubmitting = false;
        FocusScope.of(context).requestFocus(_otpFocus);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
      _autoSubmitting = false;
    }
  }

  Widget _buildOtpBoxes(BuildContext context) {
    const length = 5;
    final text = _otpCtrl.text;
    final isFocused = _otpFocus.hasFocus;
    final nextIndex = text.length.clamp(0, length - 1);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(_otpFocus);
        _otpCtrl.selection =
            TextSelection.collapsed(offset: _otpCtrl.text.length);
      },
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: List.generate(length, (i) {
          final char = i < text.length ? text[i] : '';
          final bool highlight = isFocused && i == nextIndex;
          return Container(
            width: 48,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: highlight ? (goldColor) : Colors.grey.shade300,
                width: highlight ? 1.8 : 1.2,
              ),
            ),
            child: Text(
              char,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHiddenField() {
    return SizedBox(
      height: 1,
      width: 1,
      child: TextField(
        controller: _otpCtrl,
        focusNode: _otpFocus,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(5),
        ],
        cursorColor: Colors.transparent,
        decoration:
            const InputDecoration(border: InputBorder.none, isCollapsed: true),
        enableInteractiveSelection: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
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
        child: TextSelectionTheme(
          data: TextSelectionThemeData(
            selectionHandleColor: goldColor,
            selectionColor: goldColor.withOpacity(0.2),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHiddenField(),
                Image.asset('assets/email_verification.png', height: 100),
                const SizedBox(height: 16),
                Text(
                  'E-posta Adresini Doğrula',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lütfen size gönderilen 5 haneli kodu aşağıya giriniz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                _buildOtpBoxes(context),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Get.to(() => const RegisterSendMailPage()),
                  child: const Text.rich(
                    TextSpan(
                      text: 'E‑mail adresini değiştirmek ister misin? ',
                      children: [
                        TextSpan(
                          text: 'Değiştir',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.brown),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: isLoading || _otpCtrl.text.length != 5
                        ? null
                        : _submitCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 3, color: Colors.white),
                          )
                        : const Text('E‑maili Doğrula',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    final ok = await AuthService.resendVerifyCode(userId);
                    if (ok) {
                      successSnackbar('Başarılı', 'Kod tekrar gönderildi.');
                    } else {
                      errorSnackbar('Hata', 'Kod gönderilemedi.');
                    }
                  },
                  child: const Text(
                    'Kodu Tekrar Gönder',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.black54),
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
