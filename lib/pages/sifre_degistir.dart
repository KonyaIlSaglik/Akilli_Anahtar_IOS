import 'package:akilli_anahtar/models/kullanici_giris_result.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/services/web/web_service.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:xml/xml.dart';

import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/custom_text_field.dart';

class SifreDegistirPage extends StatefulWidget {
  const SifreDegistirPage({Key? key}) : super(key: key);

  @override
  State<SifreDegistirPage> createState() => _SifreDegistirPageState();
}

class _SifreDegistirPageState extends State<SifreDegistirPage> {
  bool keboardVisible = false;
  KullaniciGirisResult? user;
  String password = "";
  final oldPasswordCont = TextEditingController(text: "");
  final oldPasswordFocus = FocusNode();
  final newPasswordCont = TextEditingController(text: "");
  final newPasswordFocus = FocusNode();
  final newPasswordAgainCont = TextEditingController(text: "");
  final newPasswordAgainFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardVisibilityController.onChange.listen((bool visible) {
      setState(() {
        keboardVisible = visible;
      });
    });
    LocalDb.get(userKey).then((value) {
      setState(() {
        user =
            KullaniciGirisResult.fromXML(XmlDocument.parse(value!).rootElement);
      });
    });
    LocalDb.get(passwordKey).then((value) {
      setState(() {
        password = value!;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    //FocusScope.of(context).dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: mainColor,
      ),
      body: PopScope(
        onPopInvoked: (didPop) async {
          Navigator.pop(context);
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
                  height: height * 0.70,
                  child: Card(
                    color: mainColor,
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: height * 0.03),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(
                              keboardVisible ? height * 0.01 : height * 0.025,
                            ),
                            child: Text(
                              "Şifre Değiştir",
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
                            controller: oldPasswordCont,
                            focusNode: oldPasswordFocus,
                            nextFocus: newPasswordFocus,
                            icon: Icon(Icons.lock),
                            hintText: "Eski Şifre",
                            isPassword: true,
                          ),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: height * 0.020),
                            child: CustomTextField(
                              controller: newPasswordCont,
                              focusNode: newPasswordFocus,
                              nextFocus: newPasswordAgainFocus,
                              icon: Icon(Icons.lock),
                              hintText: "Yeni Şifre",
                              isPassword: true,
                            ),
                          ),
                          CustomTextField(
                            controller: newPasswordAgainCont,
                            focusNode: newPasswordAgainFocus,
                            icon: Icon(Icons.lock),
                            hintText: "Yeni Şifre Tekrar",
                            isPassword: true,
                          ),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: height * 0.025),
                            child: kaydetButon(height),
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

  kaydetButon(double height) {
    return ButtonTheme(
      child: ElevatedButton(
        onPressed: () async {
          sifreDegistir(context);
        },
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          minimumSize: Size(double.infinity, height * 0.075),
        ),
        child: Text(
          "KAYDET",
          style: TextStyle(
              fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize),
        ),
      ),
    );
  }

  sifreDegistir(context) async {
    if (oldPasswordCont.text != password) {
      CherryToast.error(
        toastPosition: Position.bottom,
        title: Text("Hatalı şifre"),
      ).show(context);
      return;
    }
    if (newPasswordCont.text.isEmpty) {
      CherryToast.error(
        toastPosition: Position.bottom,
        title: Text("Yeni Şifre boş olamaz"),
      ).show(context);
      return;
    }
    if (newPasswordCont.text != newPasswordAgainCont.text) {
      CherryToast.error(
        toastPosition: Position.bottom,
        title: Text("Şifreler eşit değil"),
      ).show(context);
      return;
    }
    var result = await WebService.kullaniciSifreDegistir(
        kad: user!.kad, eskiSifre: password, yeniSifre: newPasswordCont.text);
    if (result != null && result) {
      CherryToast.success(
        toastPosition: Position.bottom,
        title: Text("Şifre güncellendi"),
      ).show(context);
      setState(() {
        password = newPasswordCont.text;
      });
      await LocalDb.add(passwordKey, password);
      oldPasswordCont.clear();
      newPasswordCont.clear();
      newPasswordAgainCont.clear();
    }
  }

  otherButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          child: Text(
            'Vazgeç',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
