import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/pages/home/home_page.dart';
import 'package:akilli_anahtar/widgets/custom_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/custom_text_field.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool? checkBoxValue = true;
  bool keboardVisible = false;
  bool loading = false;
  final passwordFocus = FocusNode();
  final passwordcon = TextEditingController();
  final userFocus = FocusNode();
  final usercon = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    var keyboardVisibilityController = KeyboardVisibilityController();

    keyboardVisibilityController.onChange.listen((bool visible) {
      if (mounted) {
        setState(() {
          keboardVisible = visible;
        });
      }
    });
    _authController.loadLoginInfo().then(
      (value) {
        usercon.text = _authController.loginModel.value.userName;
        passwordcon.text = _authController.loginModel.value.password;
      },
    );
  }

  sifemiUnuttumDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Şifremi Unuttum"),
          content: Text("Yeni şifreniz kayıtlı mail adresinize gönderilecek."),
          actions: [
            TextButton(
              child: Text(
                'Vazgeç',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Tamam',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  girisButon(double height) {
    return ButtonTheme(
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: OutlinedButton(
          onPressed: () async {
            setState(() {
              loading = true;
            });
            login(context);
          },
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            minimumSize: Size(double.infinity, height * 0.075),
          ),
          child: Text(
            "OTURUM AÇ",
            style: TextStyle(
              color: Colors.black,
              fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize,
            ),
          ),
        ),
      ),
    );
  }

  login(context) async {
    if (usercon.text.trim().isEmpty) {
      errorSnackbar('Hata', 'Kullanıcı adı boş geçilemez');
      return;
    }
    if (passwordcon.text.isEmpty) {
      errorSnackbar('Hata', 'Sifre boş geçilemez');
      return;
    }
    if (!checkBoxValue!) {
      errorSnackbar('Hata', 'Gizlilik Sözleşmesinin onaylanması zorunlu');
      return;
    }

    await _authController.login(usercon.text, passwordcon.text);

    if (_authController.isLoggedIn.value) {
      Get.to(() => HomePage());
    } else {
      passwordcon.text = "";
    }
  }

  otherButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            //sifemiUnuttumDialog();
          },
          child: Text(
            "",
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
            ),
          ),
        ),
        TextButton(
          child: Text(
            'Çıkış',
            style: TextStyle(
              color: Colors.white,
              fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
            ),
          ),
          onPressed: () {
            exitApp(context);
          },
        ),
      ],
    );
  }

  sozlesmeMetni() {
    return Row(
      children: [
        Checkbox(
          value: checkBoxValue,
          checkColor: Colors.black,
          activeColor: Colors.white,
          onChanged: (value) {
            setState(() {
              checkBoxValue = value;
            });
          },
        ),
        Flexible(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
                overflow: TextOverflow.ellipsis,
              ),
              children: [
                TextSpan(
                    text: "Gizlilik Sözleşmesini",
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        gizlilikSozlesmesi();
                      }),
                TextSpan(text: " okudum. Kabul ediyorum."),
              ],
            ),
          ),
        ),
      ],
    );
  }

  gizlilikSozlesmesi() {
    final Uri url = Uri.parse(gizlilikUrl);
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          body: Center(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: url),
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                return ServerTrustAuthResponse(
                    action: ServerTrustAuthResponseAction.PROCEED);
              },
            ),
          ),
          persistentFooterAlignment: AlignmentDirectional.center,
          persistentFooterButtons: [
            ElevatedButton.icon(
              icon: Icon(
                Icons.close,
                color: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  checkBoxValue = false;
                });
              },
              label: Text("Vazgeç"),
            ),
            ElevatedButton.icon(
              icon: Icon(
                Icons.check,
                color: Colors.green,
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  checkBoxValue = true;
                });
              },
              label: Text("İzin Veriyorum"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: PopScope(
        onPopInvoked: (didPop) async {
          exitApp(context);
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: height * 0.030,
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: height * 0.04),
                  child: SizedBox(
                    height: keboardVisible ? height * 0.10 : height * 0.20,
                    child: Image.asset(
                      "assets/anahtar.png",
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.65,
                  child: Card(
                    elevation: 0,
                    color: goldColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: height * 0.03),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(
                              keboardVisible ? height * 0.01 : height * 0.025,
                            ),
                            child: Text(
                              "GİRİŞ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headlineLarge!
                                    .fontSize,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          CustomTextField(
                            controller: usercon,
                            focusNode: userFocus,
                            nextFocus: passwordFocus,
                            hintText: "Kullanıcı Adı ya da Mail",
                            icon: Icon(Icons.person),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: height * 0.020),
                            child: CustomTextField(
                              controller: passwordcon,
                              focusNode: passwordFocus,
                              hintText: "Şifre",
                              icon: Icon(Icons.lock),
                              isPassword: true,
                            ),
                          ),
                          sozlesmeMetni(),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: height * 0.01),
                            child: Obx(() {
                              return CustomButton(
                                title: "OTURUM AÇ",
                                loading: _authController.isLoading.value,
                                onPressed: () {
                                  login(context);
                                },
                              );
                            }),
                          ),
                          otherButtons(),
                        ],
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
