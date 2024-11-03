import 'package:akilli_anahtar/controllers/login_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class LoginPageFormPrivacyPolicy extends StatefulWidget {
  const LoginPageFormPrivacyPolicy({super.key});

  @override
  State<LoginPageFormPrivacyPolicy> createState() =>
      _LoginPageFormPrivacyPolicyState();
}

class _LoginPageFormPrivacyPolicyState
    extends State<LoginPageFormPrivacyPolicy> {
  LoginController loginController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: loginController.privacyPolicy.value,
          activeColor: goldColor,
          onChanged: (value) {
            setState(() {
              loginController.privacyPolicy.value = value!;
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
                      color: goldColor,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        gizlilikSozlesmesi();
                      }),
                TextSpan(
                    text: " okudum. Kabul ediyorum.",
                    style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  gizlilikSozlesmesi() {
    final WebUri url = WebUri(gizlilikUrl);
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          body: Center(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: url),
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                return ServerTrustAuthResponse(
                  action: ServerTrustAuthResponseAction.PROCEED,
                );
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
                  loginController.privacyPolicy.value = false;
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
                  loginController.privacyPolicy.value = true;
                });
              },
              label: Text("İzin Veriyorum"),
            ),
          ],
        );
      },
    );
  }
}
